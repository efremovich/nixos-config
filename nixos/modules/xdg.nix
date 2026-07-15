# Enable from profile/host: xdg.portal.enable = true;
{ lib, pkgs, config, ... }:
{
  config = lib.mkIf config.xdg.portal.enable {
    xdg.portal = {
      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
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
