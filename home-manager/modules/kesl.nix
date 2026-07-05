{
  config,
  lib,
  pkgs,
  options,
  user ? "efremov",
  ...
}:
let
  cfg = config.kesl;
  installDir = "/opt/kaspersky/kesl";
  marker = "CCFAFCA1-F619-4618-B8C1-107EF7694A0C-ARCHIVE:";
  installerStore = "/usr/local/share/kesl-installer/KESL_12-4.sh";
  systemdOverlay = "/tmp/kesl-etc-systemd";
  launcherInstallDir = "/var/opt/kaspersky/kesl/install_12.4.0.1225/opt/kaspersky/kesl";
  isHomeManager = options ? home;

  autoinstallIni = pkgs.writeText "kesl-autoinstall.ini" ''
    EULA_AGREED=yes
    PRIVACY_POLICY_AGREED=yes
    USE_KSN=no
    GROUP_CLEAN=yes
    CONFIGURE_SELINUX=no
  '';

  systemctlWrapper = pkgs.writeShellScriptBin "systemctl" ''
    if [ "$1" = start ] && [ "$2" = kesl.service ]; then
      if ${installDir}/libexec/launcher --status >/dev/null 2>&1; then
        exit 0
      fi
      exec ${installDir}/libexec/launcher
    fi
    exec ${pkgs.systemd}/bin/systemctl "$@"
  '';

  keslControl = pkgs.writeShellScriptBin "kesl-control" ''
    set -euo pipefail
    kesl_bin=${installDir}/bin/kesl-control

    if [ ! -x "$kesl_bin" ]; then
      echo "KESL is not installed at ${installDir}" >&2
      exit 1
    fi

    exec "$kesl_bin" "$@"
  '';

  installerCandidates = lib.filter (p: p != null) [
    cfg.installerPath
    "/home/${user}/Downloads/KESL_12-4.sh"
    "/home/${user}/.nix/nixos/installers/KESL_12-4.sh"
  ];

  installScript = ''
    set -euo pipefail

    prepare_vendor_paths() {
      mkdir -p /usr/bin /usr/sbin
      ln -sfn ${pkgs.systemd}/bin/systemctl /usr/bin/systemctl 2>/dev/null || true
      ln -sfn ${pkgs.shadow}/bin/groupadd /usr/bin/groupadd 2>/dev/null || true
      ln -sfn ${pkgs.shadow}/bin/useradd /usr/bin/useradd 2>/dev/null || true
      ln -sfn ${pkgs.shadow}/bin/usermod /usr/bin/usermod 2>/dev/null || true
      ln -sfn ${pkgs.shadow}/bin/groupmod /usr/bin/groupmod 2>/dev/null || true
      ln -sfn ${pkgs.shadow}/bin/passwd /usr/bin/passwd 2>/dev/null || true
      ln -sfn ${pkgs.shadow}/sbin/groupadd /usr/sbin/groupadd 2>/dev/null || true
      ln -sfn ${pkgs.shadow}/sbin/useradd /usr/sbin/useradd 2>/dev/null || true
      ln -sfn ${pkgs.shadow}/sbin/usermod /usr/sbin/usermod 2>/dev/null || true
      ln -sfn ${pkgs.shadow}/sbin/groupmod /usr/sbin/groupmod 2>/dev/null || true
      ln -sfn ${pkgs.coreutils}/bin/chown /usr/bin/chown 2>/dev/null || true
    }

    is_kesl_configured() {
      grep -qE '^EulaId=.+$' /var/opt/kaspersky/kesl/common/agreements.ini 2>/dev/null
    }

    configure_kesl() {
      if [ ! -x ${installDir}/bin/setup ]; then
        echo "KESL is not installed yet." >&2
        return 1
      fi

      if is_kesl_configured; then
        echo "KESL already configured."
        return 0
      fi

      if ${installDir}/libexec/launcher --status >/dev/null 2>&1; then
        echo "KESL is already running."
        return 0
      fi

      ln -sfn ${systemctlWrapper}/bin/systemctl /usr/bin/systemctl
      trap 'ln -sfn ${pkgs.systemd}/bin/systemctl /usr/bin/systemctl' RETURN
      ${installDir}/bin/setup --autoinstall=${autoinstallIni} || true

      if is_kesl_configured || ${installDir}/libexec/launcher --status >/dev/null 2>&1; then
        echo "KESL configured successfully."
        return 0
      fi

      echo "KESL configuration incomplete." >&2
      return 1
    }

    if [ -d "${installDir}" ] && [ -x "${installDir}/bin/kesl-control" ]; then
      configure_kesl || true
      exit 0
    fi

    if [ ! -f ${installerStore} ]; then
      echo "KESL installer not found at ${installerStore}" >&2
      exit 1
    fi

    workdir="$(mktemp -d)"
    systemd_mounted=false

    cleanup() {
      if [ "$systemd_mounted" = true ] && mountpoint -q /etc/systemd/system; then
        umount /etc/systemd/system
      fi
      rm -rf "$workdir" ${systemdOverlay}
    }
    trap cleanup EXIT

    prepare_vendor_paths

    archive_line=$(grep -an '^${marker}$' ${installerStore} | cut -d: -f1 | tail -1)
    tail -n +$((archive_line + 1)) ${installerStore} | tar -xzf - -C "$workdir"

    mkdir -p /var/lib/dpkg
    touch /var/lib/dpkg/status

    rm -rf ${installDir}/* /var/opt/kaspersky/kesl/*
    dpkg-deb -x "$workdir/kesl_12.4.0-1225_amd64.deb" /

    rm -rf ${systemdOverlay}
    mkdir -p ${systemdOverlay}
    cp -a /etc/systemd/system/. ${systemdOverlay}/
    mount --bind ${systemdOverlay} /etc/systemd/system
    systemd_mounted=true

    chmod +x ${launcherInstallDir}/libexec/launcher
    if ! ${launcherInstallDir}/libexec/launcher \
      --install "$(date +%s)" --package-type deb; then
      echo "KESL launcher reported an error; checking install result..."
    fi

    if mountpoint -q /etc/systemd/system; then
      umount /etc/systemd/system
      systemd_mounted=false
    fi

    if [ ! -x "${installDir}/bin/kesl-control" ]; then
      echo "KESL installation incomplete." >&2
      exit 1
    fi

    configure_kesl
  '';
in
{
  options.kesl = {
    enable = lib.mkEnableOption "Kaspersky Endpoint Security for Linux";

    installerPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to KESL_12-4.sh. When null, Downloads and nixos/installers are checked.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.recursiveUpdate
      (lib.optionalAttrs isHomeManager {
        home.packages = [ keslControl ];
      })
      (lib.optionalAttrs (!isHomeManager) {
        # NixOS stage-2-init.sh sets /nix/store to 1775 root:nixbld on every boot
        # (multi-user Nix). kesl-control rejects group-writable store directories.
        system.activationScripts.kesl-nix-store-permissions = {
          text = ''
            if [ -d /nix/store ]; then
              chmod 555 /nix/store
            fi
          '';
        };

        system.activationScripts.kesl-installer = {
          deps = [
            "kesl-nix-store-permissions"
            "users"
          ];
          text = ''
            mkdir -p /usr/local/share/kesl-installer
            for candidate in ${lib.concatStringsSep " " installerCandidates}; do
              if [ -f "$candidate" ]; then
                cp "$candidate" ${installerStore}
                chmod 644 ${installerStore}
                break
              fi
            done
          '';
        };

        systemd.services.kesl-install = {
          description = "Install and configure Kaspersky Endpoint Security for Linux";
          wantedBy = [ "multi-user.target" ];
          before = [ "kesl.service" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            Restart = "no";
          };
          path = with pkgs; [
            bash
            coreutils
            dpkg
            gnugrep
            gnused
            gnutar
            gzip
            systemd
            util-linux
          ];
          script = installScript;
        };

        systemd.services.kesl = {
          description = "Kaspersky Endpoint Security for Linux";
          after = [
            "local-fs.target"
            "network.target"
            "kesl-install.service"
          ];
          wants = [ "kesl-install.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "forking";
            KillMode = "control-group";
            SendSIGKILL = true;
            PIDFile = "/run/wdserver.pid";
            TimeoutStartSec = 600;
            TimeoutStopSec = 600;
            Restart = "on-failure";
            RestartSec = "30s";
            ExecStart = "${installDir}/libexec/launcher";
            ExecStop = "${installDir}/libexec/launcher --stop";
          };
        };
      })
  );
}
