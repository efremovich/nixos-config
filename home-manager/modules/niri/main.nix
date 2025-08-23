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
    ];

    xdg.configFile."niri/config.kdl".text = let
      cfg = config.programs.niri.settings;
      toKdl = v:
        if lib.isString v then
          ''"${v}"''
        else if lib.isBool v then
          (if v then "true" else "false")
        else if lib.isInt v then
          toString v
        else if lib.isList v then
          "(${lib.concatMapStringsSep " " toKdl v})"
        else if lib.isAttrs v then ''
          {
          ${lib.concatStringsSep "\n"
          (lib.mapAttrsToList (k: v: "${k} ${toKdl v}") v)}
          }'' else
          throw "Unsupported type";
    in toKdl cfg;

    # Systemd service to start Niri
    systemd.user.services.niri = {
      description = "Niri Wayland Compositor";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session-pre.target" ];
      after = [ "graphical-session-pre.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.niri}/bin/niri --session";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
