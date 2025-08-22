{ config, pkgs, lib, ... }:
let
  wallpaperUrl = "https://w.wallhaven.cc/full/3l/wallhaven-3l5kpv.jpg";
  wallpaperPath = "${config.home.dir}/Pictures/wallpaper.png";
in {
  options.programs.swaybg = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable swaybg for setting wallpaper.";
    };
    wallpaperUrl = lib.mkOption {
      type = lib.types.str;
      default = wallpaperUrl;
      description = "URL of the wallpaper image.";
    };
    wallpaperPath = lib.mkOption {
      type = lib.types.str;
      default = wallpaperPath;
      description = "Local path to save the wallpaper.";
    };
  };

  config = lib.mkIf config.programs.swaybg.enable {
    home.packages = [ pkgs.swaybg ];

    # Скачиваем изображение при первом запуске
    home.file."Pictures/wallpaper.png".source = builtins.fetchurl {
      url = config.programs.swaybg.wallpaperUrl;
      sha256 = "sha256-kko5Uiq7H0DqiT2aDYbaQCNRzs+5AleaATzsXi3xgQA=";
    };

    # Автозапуск swaybg через systemd user service
    systemd.user.services.swaybg = {
      description = "Set and update wallpaper using swaybg";
      after = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart =
          "${pkgs.swaybg}/bin/swaybg --image ${wallpaperPath} --mode fill --output *";
        Restart = "always";
        RestartSec = 1;
      };
    };

    # Обновление переменной окружения XDG_CURRENT_DESKTOP
    environment.sessionVariables.XDG_CURRENT_DESKTOP = "niri";
  };
}
