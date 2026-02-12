# GSettings/dconf для приложений под Wayland (niri и др.).
# Нужно для FreeCAD и других приложений, использующих GSettings.
{ pkgs, ... }: {
  programs.dconf.enable = true;

  # Базовые схемы рабочего стола (органайзер файлов, шрифты и т.д.).
  # Нужны для корректной работы диалогов и интеграции под Wayland.
  environment.systemPackages = [ pkgs.gsettings-desktop-schemas ];
}
