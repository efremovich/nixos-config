{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.programs.niri.enable {
    services.displayManager.gdm.enable = true;

    # Схемы GSettings (org.gtk.Settings.FileChooser и др.) для GTK-приложений.
    # /run/current-system/sw/share добавляется в XDG_DATA_DIRS автоматически.
    environment.sessionVariables = {
      XDG_DATA_DIRS = [
        "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
        "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
      ];
    };

    programs.dconf.enable = true;
  };
}
