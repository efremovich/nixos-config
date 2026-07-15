{ pkgs, lib, config, ... }:
{
  config = lib.mkIf config.programs.niri.enable {
    services.displayManager.gdm.enable = true;

    # Схемы GSettings (org.gtk.Settings.FileChooser и др.) для GTK-приложений
    environment.sessionVariables = {
      XDG_DATA_DIRS = [
        "/run/current-system/sw/share"
        "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
        "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
      ];
    };

    programs.dconf.enable = true;
  };
}
