{ pkgs, ... }:
{
  home.packages = with pkgs; [
    imv
    mpv
    ffmpeg
    ffmpegthumbnailer
    mediainfo
    yt-dlp
    ueberzugpp
    yandex-music
  ];
}
