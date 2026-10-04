{ pkgs, lib, ... }:
let
  # В репозитории остаются только id серверов: имя (пункт меню fuzzel), хост,
  # пользователь и пароль читаются в рантайме из /run/secrets/rdp_<id>_*.
  ids = [
    "holding"
    "holding_buh"
    "autokart"
  ];

  size = "1920x2110";

  idsRows = lib.concatMapStringsSep "\n" (id: "  ${id}") ids;

  rdp = pkgs.writeShellApplication {
    name = "rdp";
    runtimeInputs = with pkgs; [
      fuzzel
      freerdp
      libnotify
      coreutils
    ];
    text = ''
      secret_dir=/run/secrets
      IDS=(
      ${idsRows}
      )

      NAMES=()
      for id in "''${IDS[@]}"; do
        file="$secret_dir/rdp_''${id}_name"
        if [ ! -r "$file" ]; then
          printf 'Секрет %s недоступен\n' "$file" >&2
          exit 1
        fi
        NAMES+=("$(cat "$file")")
      done

      if [ "$#" -ge 1 ]; then
        wanted="$1"
      else
        wanted="$(printf '%s\n' "''${NAMES[@]}" | fuzzel --dmenu --prompt='RDP: ')" || exit 0
      fi

      [ -n "$wanted" ] || exit 0

      selected=""
      for i in "''${!IDS[@]}"; do
        if [ "''${NAMES[$i]}" = "$wanted" ]; then
          selected="$i"
          break
        fi
      done

      if [ -z "$selected" ]; then
        printf 'Неизвестный сервер: %s\n' "$wanted" >&2
        exit 1
      fi

      id="''${IDS[$selected]}"
      name="''${NAMES[$selected]}"

      user_file="$secret_dir/rdp_''${id}_user"
      host_file="$secret_dir/rdp_''${id}_host"
      password_file="$secret_dir/rdp_''${id}_password"
      for file in "$user_file" "$host_file" "$password_file"; do
        if [ ! -r "$file" ]; then
          printf 'Секрет %s недоступен\n' "$file" >&2
          exit 1
        fi
      done

      user="$(cat "$user_file")"
      host="$(cat "$host_file")"
      password="$(cat "$password_file")"
      if [ -z "$host" ] || [ -z "$user" ]; then
        printf 'Пустой хост или пользователь для %s\n' "$id" >&2
        exit 1
      fi

      port=3389
      size=${size}

      notify-send "RDP" "Подключаюсь к $host:$port как $user" -u low || true

      set +e
      xfreerdp \
        /v:"$host:$port" \
        /u:"$user" \
        /size:"$size" \
        /audio-mode:1 \
        /microphone:format:1 \
        /clipboard \
        /dynamic-resolution \
        /cert:ignore \
        +auto-reconnect \
        /auto-reconnect-max-retries:5 \
        /bpp:32 \
        /p:"$password" \
        /drive:home,"$HOME/Documents/"
      status=$?
      set -e

      notify-send "RDP" "Сессия с $name завершена" -u low || true
      exit "$status"
    '';
  };
in
{
  home.packages = [ rdp ];

  xdg.desktopEntries.rdp = {
    name = "RDP";
    comment = "Подключение к RDP-серверам через fuzzel";
    exec = "${rdp}/bin/rdp";
    terminal = false;
    categories = [ "Network" "RemoteAccess" ];
  };
}
