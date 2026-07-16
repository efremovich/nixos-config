{ pkgs, lib, ... }:
let
  enable = true;
in
lib.mkIf enable {
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
