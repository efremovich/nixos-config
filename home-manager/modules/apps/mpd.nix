{ pkgs, ... }:
{
  services.mpd = {
    enable = true;
    musicDirectory = "~/Music";
    extraConfig = ''
      auto_update "yes"
      auto_update_depth "1"
    '';
  };

  services.mpd-mpris = {
    enable = true;
  };

  home.packages = with pkgs; [
    mpd
    mpc-cli
    ncmpcpp
  ];

  systemd.user.services.mpd-init = {
    Unit = {
      Description = "Initialize MPD playlist";
      After = [ "mpd.service" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.mpc-cli}/bin/mpc clear && ${pkgs.mpc-cli}/bin/mpc add http://www.4duk.ru/4duk/128m3u.m3u";
    };

    Install.WantedBy = [ "default.target" ];
  };
}
