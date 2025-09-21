# home-manager/modules/niri/main.nix
{ config, pkgs, lib, ... }:
let cfg = config.programs.niri;
in {
  options.programs.niri = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Niri Wayland compositor";
    };
  };

  config = lib.mkIf cfg.enable {
    # Устанавливаем niri (уже есть через оверлей)
    home.packages = with pkgs; [
      niri
      wlrctl
      grimblast
      slurp
      wl-clipboard
      cliphist
      brightnessctl
    ];

    # # Переменные окружения
    # environment.sessionVariables = {
    #   MOZ_ENABLE_WAYLAND = "1";
    #   __GL_GSYNC_ALLOWED = "0";
    #   __GL_VRR_ALLOWED = "0";
    #   XDG_CURRENT_DESKTOP = "niri";
    #   XDG_SESSION_DESKTOP = "niri";
    # };

    # Автозапуск сервисов
    systemd.user.services = {
      swayidle = {
        description = "Idle management for niri";
        after = [ "graphical-session.target" ];
        serviceConfig = {
          ExecStart =
            "${pkgs.swayidle}/bin/swayidle timeout 300 'swaylock -f' timeout 600 'wlrctl output * dpms off' resume 'wlrctl output * dpms on' before-sleep 'swaylock -f'";
          Restart = "always";
          RestartSec = 1;
        };
      };
      swaylock = {
        description = "Screen locker";
        serviceConfig = {
          ExecStart =
            "${pkgs.swaylock}/bin/swaylock -f --screenshots --effect-blur 5x5 --ring-color bb00cc --inside-color 00000000 --ring-ver-color bb00cc --ring-wrong-color ff0000";
        };
      };
    };

    # Цель: автозапуск сервисов
    systemd.user.targets.niri = {
      description = "Niri target";
      wants = [ "swayidle.service" ];
      after = [ "graphical-session.target" ];
    };
  };
}
