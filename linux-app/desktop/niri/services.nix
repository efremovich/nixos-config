{ lib, ... }: {
  services = {
    # Ref: https://github.com/hallettj/home.nix/blob/main/home-manager/features/niri/default.nix
    blueman-applet.enable = true;

    network-manager-applet.enable = true;

    # Wallpaper
    swww.enable = true;

    # Use Gnome Keyring as SSH agent
    gnome-keyring = {
      enable = true;
      components = [ "pkcs11" "secrets" "ssh" ];
    };

    # OSD for volume, brightness changes
    swayosd.enable = true;
  };
  systemd = {
    user = {
      services = {
        blueman-applet.Install = lib.mkForce {
          # Replace "graphical-session.target" so that this only starts when Niri starts.
          WantedBy = [ "tray.target" ];
        };
        network-manager-applet.Install = lib.mkForce {
          # Replace "graphical-session.target" so that this only starts when Niri starts.
          WantedBy = [ "tray.target" ];
        };
        swayosd = {
          # Adjust swayosd restart policy - it's failing due to too many restart
          # attempts when resuming from sleep
          Unit.StartLimitIntervalSec = lib.mkForce 1;
        };
      };

      # Some services, like blueman-applet, require a `tray` target. Typically Home
      # Manager sets this target in WM modules, but it's not set up for Niri yet.
      targets.tray = {
        Unit = { After = [ "niri.service" ]; };
        Install = { WantedBy = [ "niri.service" ]; };
      };
    };
  };
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";

  # services.hyprpaper = { enable = true; };
}
