{
  pkgs,
  inputs,
  ...
}:
let
  # Стабильный nixpkgs часто отстаёт; для потоков нужен mpd-mpris ≥0.4.2 —
  # иначе при том же URL радио MPRIS не обновляет title/artist при смене трека в ICY,
  # хотя mpc уже показывает новые данные.
  # mpd-mpris-pkg = inputs.unstable.legacyPackages.${pkgs.system}.mpd-mpris;
in
{
  services.mpd = {
    enable = true;
    musicDirectory = "~/Music";
    extraConfig = ''
      auto_update "yes"
      auto_update_depth "1"

      audio_output {
        type "pipewire"
        name "PipeWire"
      }

      metadata_to_use "artist,title,album,track,name"
      # Чтение метаданных из icecast потока
      input {
        plugin "curl"
      }
    '';
  };

  services.mpd-mpris = {
    enable = true;
  };

  home.packages = with pkgs; [
    mpd
    mpc
    ncmpcpp
  ];

  systemd.user.services.mpd-radio = {
    Unit = {
      Description = "Add radio playlist to MPD";
      After = [ "mpd.service" ];
      Requires = [ "mpd.service" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.mpc}/bin/mpc clear && ${pkgs.mpc}/bin/mpc add http://radio.4duk.ru/4duk128.mp3 && ${pkgs.mpc}/bin/mpc play'";
      RemainAfterExit = true;
    };

    Install.WantedBy = [ "default.target" ];
  };
}
