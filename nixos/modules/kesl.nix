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
  # util-linux (lsblk) and lshw are required by Network Agent hardware inventory.
  keslPath = lib.makeBinPath [
    pkgs.bash
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.gawk
    pkgs.procps
    pkgs.gnused
    pkgs.kmod
    pkgs.util-linux
    pkgs.lshw
  ];
  klnagentPath = lib.makeBinPath [
    pkgs.coreutils
    pkgs.util-linux
    pkgs.lshw
    pkgs.pciutils
  ];
  keslControl = "/opt/kaspersky/kesl/bin/kesl-control";
  keslUnit = pkgs.writeText "kesl.service" ''
    [Unit]
    Description=kesl
    After=kesl-fix-perms.service
    Wants=kesl-fix-perms.service

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
  klnagentPathDropIn = pkgs.writeText "klnagent-path.conf" ''
    [Service]
    Environment="PATH=${klnagentPath}:/run/current-system/sw/bin"
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

    # Hardware inventory helpers for Network Agent (lsblk from util-linux, lshw).
    environment.systemPackages = [
      pkgs.util-linux
      pkgs.lshw
    ];

    # KESL integrity / remote client checks refuse access when:
    # 1) /nix/store is group-writable (Nix multi-user default 1775/nixbld),
    # 2) any path component to product trees is owned by a non-root user
    #    (we have seen /etc or /var as efremov → RemoteConnectionRejected),
    # 3) install trees / binaries are writable by group/other.
    #
    # nix-daemon resets /nix/store to 1775 on start (and sometimes later), so
    # clamp via ExecStartPost + a periodic timer. chmod on a read-only store
    # must never fail the daemon (exit 0 always).
    systemd.services.nix-daemon.serviceConfig.ExecStartPost = [
      "+${pkgs.writeShellScript "kesl-clamp-nix-store-mode" ''
        set -uo pipefail
        if mountpoint -q /nix/store 2>/dev/null; then
          mount -o remount,rw /nix/store 2>/dev/null || true
          chmod 555 /nix/store 2>/dev/null || true
          mount -o remount,ro /nix/store 2>/dev/null || true
        else
          chmod 555 /nix/store 2>/dev/null || true
        fi
        exit 0
      ''}"
    ];

    # Keep parent dirs root-owned across boots (KESL walks the full path).
    systemd.tmpfiles.rules = [
      "z /etc 0755 root root -"
      "z /var 0755 root root -"
      "z /opt 0755 root root -"
      "z /etc/opt 0755 root root -"
      "z /var/opt 0755 root root -"
    ];

    # Shared fix used by activation, oneshot service, and timer.
    # Keep this script idempotent and never fail the caller hard.
    systemd.services.kesl-fix-perms = {
      description = "Fix permissions required by KESL / Network Agent integrity checks";
      wantedBy = [ "multi-user.target" ];
      before = [
        "kesl.service"
        "kesl-postconfigure.service"
      ];
      after = [ "local-fs.target" ];
      path = [
        pkgs.coreutils
        pkgs.util-linux
      ];
      serviceConfig = {
        Type = "oneshot";
        # Must stay inactive after run so the timer can re-trigger the clamp.
        RemainAfterExit = false;
      };
      script = ''
        set -uo pipefail

        if [ -d /nix/store ]; then
          if mountpoint -q /nix/store 2>/dev/null; then
            mount -o remount,rw /nix/store 2>/dev/null || true
            chmod 555 /nix/store 2>/dev/null || true
            mount -o remount,ro /nix/store 2>/dev/null || true
          else
            chmod 555 /nix/store 2>/dev/null || true
          fi
        fi

        for p in /etc /var /opt /etc/opt /var/opt; do
          if [ -e "$p" ]; then
            chown root:root "$p" 2>/dev/null || true
            chmod 755 "$p" 2>/dev/null || true
          fi
        done

        for d in \
          /opt/kaspersky \
          /opt/kaspersky/kesl \
          /opt/kaspersky/klnagent64 \
          /etc/opt/kaspersky \
          /var/opt/kaspersky \
          /var/opt/kaspersky/kesl/install-current \
          /var/opt/kaspersky/kesl/install_${cfg.packageVersion} \
          /var/opt/kaspersky/kesl/${cfg.packageVersion}_*; do
          if [ -e "$d" ]; then
            chown -R root:root "$d" 2>/dev/null || true
            chmod -R go-w "$d" 2>/dev/null || true
          fi
        done

        for f in \
          /var/opt/kaspersky/kesl/common/kesl.ini \
          /var/opt/kaspersky/kesl/common/agreements.ini; do
          if [ -e "$f" ]; then
            chown root:root "$f" 2>/dev/null || true
          fi
        done

        exit 0
      '';
    };

    # Re-apply after nix-daemon (or other tools) loosen /nix/store again.
    systemd.timers.kesl-fix-perms = {
      description = "Periodically fix KESL-related permissions";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "2min";
        OnUnitActiveSec = "3min";
        AccuracySec = "30s";
        Persistent = true;
      };
    };

    system.activationScripts.keslPermissions = {
      deps = [
        "users"
        "etc"
      ];
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

        # Parent path owners matter: KESL rejects clients if any path component
        # is writable/owned by a non-root user (e.g. /etc or /var as efremov).
        for p in /etc /var /opt /etc/opt /var/opt; do
          if [ -e "$p" ]; then
            chown root:root "$p" || true
            chmod 755 "$p" || true
          fi
        done

        for d in \
          /opt/kaspersky \
          /opt/kaspersky/kesl \
          /opt/kaspersky/klnagent64 \
          /etc/opt/kaspersky \
          /var/opt/kaspersky \
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
        # Network Agent (vendor unit) needs lsblk/lshw on PATH for inventory.
        if [ -f /etc/systemd/system/klnagent64.service ] || [ -L /etc/systemd/system/klnagent64.service ]; then
          mkdir -p /etc/systemd/system/klnagent64.service.d
          cp ${klnagentPathDropIn} /etc/systemd/system/klnagent64.service.d/path.conf
        fi
        mkdir -p /etc/systemd/system/multi-user.target.wants
        ln -sf /etc/systemd/system/kesl.service /etc/systemd/system/multi-user.target.wants/kesl.service
        systemctl daemon-reload >/dev/null 2>&1 || true
      '';
    };

    # Finish setup that the installer skipped when integrity checks failed.
    systemd.services.kesl-postconfigure = {
      description = "KESL post-configure (admin role, optional KSN)";
      after = [
        "kesl.service"
        "kesl-fix-perms.service"
      ];
      wants = [
        "kesl.service"
        "kesl-fix-perms.service"
      ];
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
        for p in /etc /var /opt /etc/opt /var/opt; do
          if [ -e "$p" ]; then
            chown root:root "$p" || true
            chmod 755 "$p" || true
          fi
        done

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
