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
    # USB Audio (XMOS UAC2 и др.): диагностика и выбор выхода
    alsa-utils
    pavucontrol
    usbutils
  ];
}
