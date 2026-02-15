{ pkgs, ... }:
{
  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk  # GTK file chooser и org.gtk.Settings.*
        xdg-desktop-portal-gnome
      ];
      config.common.default = [
        "gnome"
        "gtk"
      ];
    };
  };
}
