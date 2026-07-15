{ pkgs, ... }:
{
  services.swaync = {
    enable = true;
    # Don't recursive-copy this directory into ~/.config/swaync (that also dropped default.nix).
    style = ./style.css;
    settings = {
      positionX = "right";
      positionY = "top";
      control-center-radius = 1;
      fit-to-screen = true;
      layer-shell = true;
      layer = "overlay";
      control-center-layer = "overlay";
      cssPriority = "user";
      notification-icon-size = 64;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      timeout = 10;
      timeout-low = 5;
      timeout-critical = 0;

      # mpris widget caused assert spam / memory growth; MPRIS lives in waybar.
      widgets = [
        "inhibitors"
        "dnd"
        "notifications"
      ];
      widget-config = {
        title = {
          text = "Notifications";
          clear-all-button = true;
          button-text = "Clear All";
        };
        dnd = {
          text = "Do Not Disturb";
        };
      };
    };
  };

  # Ensure client is on PATH for waybar on-click / exec.
  home.packages = [ pkgs.swaynotificationcenter ];
}
