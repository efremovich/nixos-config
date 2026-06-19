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
    exec ${pkgs.glibc}/bin/ld-linux-x86-64.so.2 \
      --library-path "${installDir}/lib64:${pkgs.glibc}/lib" \
      ${installDir}/bin/kesl-control "$@"
  '';

  installerCandidates = lib.filter (p: p != null) [
    cfg.installerPath
    "/home/${user}/Downloads/KESL_12-4.sh"
    "/home/${user}/.nix/nixos/installers/KESL_12-4.sh"
  ];
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
        home.packages = [
          pkgs.dpkg
          keslControl
        ];
      })
      (lib.optionalAttrs (!isHomeManager) {
        environment.systemPackages = [
          pkgs.dpkg
          keslControl
        ];

        system.activationScripts.kesl-installer = {
          deps = [ "users" ];
          text = ''
            mkdir -p /usr/local/share/kesl-installer
            for candidate in ${lib.concatStringsSep " " installerCandidates}; do
              if [ -f "$candidate" ]; then
                cp "$candidate" ${installerStore}
                chmod 644 ${installerStore}
                break
              fi
            done

            if [ "$(stat -c '%a' /nix/store 2>/dev/null || echo 0)" != "555" ]; then
              mount -o remount,rw /nix/store 2>/dev/null || true
              chmod 555 /nix/store 2>/dev/null || true
              mount -o remount,ro /nix/store 2>/dev/null || true
            fi

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
          '';
        };

        systemd.services.kesl-install = {
          description = "Install Kaspersky Endpoint Security for Linux";
          wantedBy = [ "multi-user.target" ];
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          before = [ "kesl-configure.service" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            Restart = "no";
          };
          path = with pkgs; [
            bash
            coreutils
            dpkg
            findutils
            gawk
            gnugrep
            gnused
            gnutar
            gzip
            procps
            systemd
            util-linux
            which
          ];
          script = ''
            set -euo pipefail

            if [ -d "${installDir}" ] && [ -x "${installDir}/bin/kesl-control" ]; then
              echo "KESL already installed, skipping."
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

            echo "Extracting KESL installer..."
            archive_line=$(grep -an '^${marker}$' ${installerStore} | cut -d: -f1 | tail -1)
            tail -n +$((archive_line + 1)) ${installerStore} | tar -xzf - -C "$workdir"

            mkdir -p /var/lib/dpkg
            touch /var/lib/dpkg/status

            rm -rf /opt/kaspersky/kesl/*
            rm -rf /var/opt/kaspersky/kesl/*

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

            if [ -d "${installDir}" ] && [ -x "${installDir}/bin/kesl-control" ]; then
              echo "KESL installed successfully."
              exit 0
            fi

            echo "KESL installation incomplete." >&2
            exit 1
          '';
        };

        systemd.services.kesl-configure = {
          description = "Initial configuration of Kaspersky Endpoint Security for Linux";
          wantedBy = [ "multi-user.target" ];
          after = [ "kesl-install.service" ];
          before = [ "kesl.service" ];
          requires = [ "kesl-install.service" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            Restart = "no";
          };
          path = with pkgs; [
            bash
            coreutils
            systemd
          ];
          script = ''
            set -euo pipefail

            if [ ! -x ${installDir}/bin/setup ]; then
              echo "KESL is not installed yet." >&2
              exit 1
            fi

            if ${installDir}/libexec/launcher --status >/dev/null 2>&1; then
              echo "KESL is already configured and running."
              exit 0
            fi

            ${pkgs.systemd}/bin/systemctl stop kesl.service 2>/dev/null || true
            ln -sfn ${systemctlWrapper}/bin/systemctl /usr/bin/systemctl
            trap 'ln -sfn ${pkgs.systemd}/bin/systemctl /usr/bin/systemctl' EXIT
            ${installDir}/bin/setup --autoinstall=${autoinstallIni} || true

            if ${installDir}/libexec/launcher --status >/dev/null 2>&1; then
              echo "KESL configured successfully."
              exit 0
            fi

            echo "KESL configuration incomplete." >&2
            exit 1
          '';
        };

        systemd.services.kesl = {
          description = "Kaspersky Endpoint Security for Linux";
          after = [
            "local-fs.target"
            "network.target"
            "kesl-configure.service"
          ];
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
