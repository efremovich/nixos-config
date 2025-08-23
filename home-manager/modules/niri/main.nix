{ config, pkgs, lib, ... }: {
  options.programs.niri = {
    enable = lib.mkEnableOption "Niri window manager";
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Niri configuration settings";
    };
  };

  config = lib.mkIf config.programs.niri.enable {
    home.packages = with pkgs; [
      # Essential Wayland utilities for Niri
      swayidle
      swaylock
      waybar
      wofi
      cliphist
      hyprpicker
      grimblast
      libnotify
      fuzzel
    ];

    # Systemd service to start Niri
    # systemd.user.services.niri = {
    #   description = "Niri Wayland Compositor";
    #   wantedBy = [ "graphical-session.target" ];
    #   wants = [ "graphical-session-pre.target" ];
    #   after = [ "graphical-session-pre.target" ];
    #   serviceConfig = {
    #     Type = "simple";
    #     ExecStart = "${pkgs.niri}/bin/niri --session";
    #     Restart = "on-failure";
    #     RestartSec = 1;
    #     TimeoutStopSec = 10;
    #   };
    # };
  };
}
