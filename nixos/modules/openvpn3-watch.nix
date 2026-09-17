{
  config,
  lib,
  pkgs,
  user,
  ...
}:
let
  cfg = config.services.openvpn3-watch;

  tfa2 = pkgs.callPackage ../../pkgs/2fa.nix { };

  # Конфигурации VPN. name — имя в openvpn3, id — префикс sops-секретов,
  # ovpn — имя секрета с .ovpn-файлом, tfa — аккаунт в 2fa (~/.2fa).
  vpns = [
    {
      name = "Astral";
      id = "astral";
      ovpn = "astral_ovpn";
      tfa = "astral_vpn";
    }
    {
      name = "AstralVPN";
      id = "astralvpn";
      ovpn = "astralvpn_ovpn";
      tfa = "astral";
    }
  ];

  vpnList = lib.concatMapStringsSep "\n" (v: "  \"${v.name}|${v.ovpn}|${v.id}|${v.tfa}\"") vpns;

  # Подключение выполняется как вручную:
  #   printf "user\npass\n$(2fa <account>)\n" | openvpn3 session-start --config <name> --background
  connectScript = pkgs.writeShellScript "openvpn3-watch.sh" ''
    set -uo pipefail

    # Максимальный возраст сессии в статусе "не подключено" (сек), после которого она считается застрявшей
    STALE_AGE=300
    # Таймаут ожидания ответа session-start (сек)
    START_TIMEOUT=20

    # name|ovpn|id|tfa
    VPN_CONFIGS=(
    ${vpnList}
    )

    ensure_config() {
      local name="$1" ovpn="$2"
      if ! openvpn3 config-manage --config "$name" --exists --quiet 2>/dev/null; then
        echo "[$name] importing config from sops"
        openvpn3 config-import --config "/run/secrets/$ovpn" --name "$name" --persistent \
          || echo "[$name] config-import failed" >&2
      fi
    }

    is_connected() {
      local name="$1"
      openvpn3 sessions-list 2>/dev/null \
        | grep -A6 "Config name: ''${name}$" \
        | grep -q "Connection, Client connected"
    }

    session_exists() {
      local name="$1"
      openvpn3 sessions-list 2>/dev/null | grep -qE "Config name: ''${name}$"
    }

    # Сессия в терминальном состоянии (auth failed / disconnected) — её надо пересоздать.
    session_failed() {
      local name="$1"
      openvpn3 sessions-list 2>/dev/null \
        | grep -A6 "Config name: ''${name}$" \
        | grep -qiE "authentication failed|client disconnected"
    }

    session_age() {
      local name="$1" line ts
      line=$(openvpn3 sessions-list 2>/dev/null \
        | grep -B3 "Config name: ''${name}$" | grep "Created:" | head -1)
      ts=$(printf '%s' "$line" | sed -n 's/.*Created: \([0-9-]* [0-9:]*\).*/\1/p')
      if [ -z "$ts" ]; then
        echo 0
      else
        date -d "$ts" +%s 2>/dev/null || echo 0
      fi
    }

    start_vpn() {
      local name="$1" id="$2" tfa="$3" user pass code
      user=$(cat "/run/secrets/''${id}_user" 2>/dev/null)
      pass=$(cat "/run/secrets/''${id}_password" 2>/dev/null)
      code=$(2fa "$tfa" 2>/dev/null | head -1 | tr -d '[:space:]')
      if [ -z "$user" ] || [ -z "$pass" ] || [ -z "$code" ]; then
        echo "[$name] missing credentials or TOTP code, will retry on next timer tick" >&2
        return 0
      fi
      printf '%s\n%s\n%s\n' "$user" "$pass" "$code" \
        | timeout "$START_TIMEOUT" openvpn3 session-start --config "$name" --background 2>&1 \
        || echo "[$name] session-start failed" >&2
    }

    connect_vpn() {
      local name="$1" ovpn="$2" id="$3" tfa="$4" now age
      echo "== [$name] =="
      ensure_config "$name" "$ovpn"

      if is_connected "$name"; then
        echo "[$name] already connected"
        return 0
      fi

      if session_exists "$name"; then
        if session_failed "$name"; then
          echo "[$name] session in failed state, disconnecting"
          openvpn3 session-manage --config "$name" --disconnect >/dev/null 2>&1 || true
          sleep 2
        else
          now=$(date +%s)
          age=$(( now - $(session_age "$name") ))
          if [ "$age" -gt "$STALE_AGE" ]; then
            echo "[$name] stale session (''${age}s), disconnecting"
            openvpn3 session-manage --config "$name" --disconnect >/dev/null 2>&1 || true
            sleep 2
          else
            echo "[$name] session in progress (''${age}s), skip"
            return 0
          fi
        fi
      fi

      echo "[$name] starting session"
      start_vpn "$name" "$id" "$tfa"
    }

    disconnect_vpn() {
      local name="$1"
      if session_exists "$name"; then
        echo "[$name] disconnecting"
        openvpn3 session-manage --config "$name" --disconnect >/dev/null 2>&1 || true
      else
        echo "[$name] no session to disconnect"
      fi
    }

    stop_all() {
      local entry name
      for entry in "''${VPN_CONFIGS[@]}"; do
        name=''${entry%%|*}
        disconnect_vpn "$name"
      done
    }

    main() {
      local action="''${1:-start}" entry name rest ovpn id tfa
      if [ "$action" = "stop" ]; then
        stop_all
        return 0
      fi
      for entry in "''${VPN_CONFIGS[@]}"; do
        name=''${entry%%|*}
        rest=''${entry#*|}
        ovpn=''${rest%%|*}
        tfa=''${rest##*|}
        id=''${rest%|*}
        id=''${id#*|}
        connect_vpn "$name" "$ovpn" "$id" "$tfa"
      done
    }

    main "$@"
  '';
in
{
  options.services.openvpn3-watch = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable the OpenVPN3 auto-connect watchdog service.";
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = (lib.genAttrs [
      "astral_user"
      "astral_password"
      "astralvpn_user"
      "astralvpn_password"
    ] (_: {
      owner = user;
    })) // {
      astral_ovpn = {
        sopsFile = ../../secrets/astral.ovpn;
        format = "binary";
        owner = user;
      };
      astralvpn_ovpn = {
        sopsFile = ../../secrets/astralvpn.ovpn;
        format = "binary";
        owner = user;
      };
    };

    systemd.services.openvpn3-watch = {
      description = "OpenVPN3 watchdog: keep VPN sessions connected";
      after = [
        "network-online.target"
        "sops-nix.service"
      ];
      wants = [ "network-online.target" ];
      path = with pkgs; [
        openvpn3
        tfa2
        coreutils
        gnugrep
        gnused
      ];
      serviceConfig = {
        Type = "oneshot";
        User = user;
        TimeoutStartSec = 60;
        ExecStart = connectScript;
      };
    };

    # Ручное отключение всех VPN-сессий (вызывается тумблером в waybar).
    systemd.services.openvpn3-watch-stop = {
      description = "OpenVPN3: disconnect all VPN sessions";
      path = with pkgs; [
        openvpn3
        coreutils
        gnugrep
        gnused
      ];
      serviceConfig = {
        Type = "oneshot";
        User = user;
        TimeoutStartSec = 60;
        ExecStart = "${connectScript} stop";
      };
    };

    systemd.timers.openvpn3-watch = {
      description = "Periodic check for OpenVPN3 connections";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "15s";
        OnUnitActiveSec = "30s";
        RandomizedDelaySec = "5s";
      };
    };
  };
}
