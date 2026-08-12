{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.kesl;
  # Tools KESL's shell scripts need (kesl-starter uses lsmod/fgrep, init.d uses
  # ps/awk/grep/sed). systemd's default PATH on NixOS is minimal, so provide one.
  keslPath = lib.makeBinPath [
    pkgs.bash
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.gawk
    pkgs.procps
    pkgs.gnused
    pkgs.kmod
  ];
  keslControl = "/opt/kaspersky/kesl/bin/kesl-control";
  keslUnit = pkgs.writeText "kesl.service" ''
    [Unit]
    Description=kesl

    [Service]
    KillMode=control-group
    Type=forking
    SendSIGKILL=yes
    PIDFile=/var/run/wdserver.pid
    ExecStart=/var/opt/kaspersky/kesl/install-current/etc/init.d/kesl start
    ExecStop=/var/opt/kaspersky/kesl/install-current/etc/init.d/kesl stop
    TimeoutSec=600

    [Install]
    WantedBy=multi-user.target
  '';
  keslPathDropIn = pkgs.writeText "kesl-path.conf" ''
    [Service]
    Environment="PATH=${keslPath}:/run/current-system/sw/bin"
  '';
in
{
  options.services.kesl = {
    enable = lib.mkEnableOption "Kaspersky Endpoint Security for Linux (KESL)";

    packageVersion = lib.mkOption {
      type = lib.types.str;
      default = "12.4.0.1225";
      description = "Installed KESL version (matches /var/opt/kaspersky/kesl/install-*).";
    };

    adminUser = lib.mkOption {
      type = lib.types.str;
      default = "root";
      description = "User allowed to administer KESL via kesl-control without extra privileges.";
    };

    useKsn = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Accept Kaspersky Security Network (KSN) statement during post-configure.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Groups required by KESL (created by its installer on other distros).
    users.groups = {
      kesladmin = { };
      kesluser = { };
      keslaudit = { };
      nokesl = { };
    };

    users.users.${cfg.adminUser}.extraGroups = lib.mkIf (cfg.adminUser != "root") [ "kesladmin" ];

    # KESL's integrity check refuses clients if:
    # 1) /nix/store is group-writable (Nix multi-user default 1775/nixbld), or
    # 2) install trees / binaries are writable by a non-root owner.
    #
    # nix-daemon resets /nix/store to 1775 on start, so also clamp it via
    # ExecStartPost (activation alone is not enough across daemon restarts).
    systemd.services.nix-daemon.serviceConfig.ExecStartPost = [
      "+${pkgs.writeShellScript "kesl-clamp-nix-store-mode" ''
        set -euo pipefail
        # Prefer plain chmod; remount only if the store is a separate mount.
        if mountpoint -q /nix/store 2>/dev/null; then
          mount -o remount,rw /nix/store 2>/dev/null || true
          chmod 555 /nix/store
          mount -o remount,ro /nix/store 2>/dev/null || true
        else
          chmod 555 /nix/store
        fi
      ''}"
    ];

    system.activationScripts.keslPermissions = {
      deps = [ "users" ];
      text = ''
        if [ -d /nix/store ]; then
          if mountpoint -q /nix/store 2>/dev/null; then
            mount -o remount,rw /nix/store 2>/dev/null || true
            chmod 555 /nix/store || true
            mount -o remount,ro /nix/store 2>/dev/null || true
          else
            chmod 555 /nix/store || true
          fi
        fi

        for d in \
          /opt/kaspersky/kesl \
          /var/opt/kaspersky/kesl/install-current \
          /var/opt/kaspersky/kesl/install_${cfg.packageVersion} \
          /var/opt/kaspersky/kesl/${cfg.packageVersion}_*; do
          if [ -e "$d" ]; then
            chown -R root:root "$d" || true
            chmod -R go-w "$d" || true
          fi
        done

        for f in \
          /var/opt/kaspersky/kesl/common/kesl.ini \
          /var/opt/kaspersky/kesl/common/agreements.ini; do
          if [ -e "$f" ]; then
            chown root:root "$f" || true
          fi
        done
      '';
    };

    # KESL's launcher copies its own unit file into /etc/systemd/system on every
    # start. On NixOS that path is a read-only symlink into the nix store, which
    # breaks KESL. Convert it to a real writable directory that still contains
    # all NixOS-managed units (copied from /etc/static/systemd/system), and keep
    # the kesl.service unit there so systemd finds it at boot. Also add a drop-in
    # that sets PATH for KESL's helper scripts (lsmod, fgrep, ...).
    system.activationScripts.keslSystemdDir = {
      deps = [
        "etc"
        "keslPermissions"
      ];
      text = ''
        if [ -L /etc/systemd/system ] || [ ! -d /etc/systemd/system ]; then
          rm -rf /etc/systemd/system
          mkdir -p /etc/systemd/system
        fi
        if [ -d /etc/static/systemd/system ]; then
          cp -a /etc/static/systemd/system/. /etc/systemd/system/
        fi
        cp ${keslUnit} /etc/systemd/system/kesl.service
        mkdir -p /etc/systemd/system/kesl.service.d
        cp ${keslPathDropIn} /etc/systemd/system/kesl.service.d/path.conf
        mkdir -p /etc/systemd/system/multi-user.target.wants
        ln -sf /etc/systemd/system/kesl.service /etc/systemd/system/multi-user.target.wants/kesl.service
        systemctl daemon-reload >/dev/null 2>&1 || true
      '';
    };

    # Finish setup that the installer skipped when integrity checks failed.
    systemd.services.kesl-postconfigure = {
      description = "KESL post-configure (admin role, optional KSN)";
      after = [ "kesl.service" ];
      wants = [ "kesl.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [
        pkgs.coreutils
        pkgs.util-linux
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        set -euo pipefail

        # Re-clamp in case nix-daemon restarted after activation.
        if [ -d /nix/store ]; then
          chmod 555 /nix/store || true
        fi

        control="${keslControl}"
        if [ ! -x "$control" ]; then
          echo "kesl-control not found at $control" >&2
          exit 1
        fi

        for _ in $(seq 1 90); do
          if [ -S /run/bl4control ] || [ -S /var/run/bl4control ]; then
            break
          fi
          sleep 1
        done

        ${lib.optionalString (cfg.adminUser != "root") ''
          echo "Granting KESL admin role to ${cfg.adminUser}..."
          "$control" --grant-role admin ${lib.escapeShellArg cfg.adminUser}
        ''}

        ${lib.optionalString cfg.useKsn ''
          echo "Accepting KSN statement..."
          "$control" --accept-ksn || true
        ''}
      '';
    };
  };
}
