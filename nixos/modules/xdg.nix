# Enable from profile/host: xdg.portal.enable = true;
{ lib, pkgs, config, ... }:
{
  config = lib.mkIf config.xdg.portal.enable {
    xdg.portal = {
      # niri реализует screencast через gnome-портал; wlr-портал не нужен.
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      config.common.default = [
        "gnome"
        "gtk"
      ];
    };
  };
}
