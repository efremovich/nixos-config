{ pkgs, lib, ... }:
let
  enable = true;
in
lib.mkIf enable {
  home.packages = with pkgs; [
    imv
    mpv
    ffmpeg
    ffmpegthumbnailer
    mediainfo
    yt-dlp
    ueberzugpp
  ];
}
