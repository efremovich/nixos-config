services.xserver = {
  displayManager.gdm.enable = true;
  desktopManager.gnome.enable = true;
}
environment.gnome.excludePackages = (with pkgs; [
  cheese # webcam tool
  evince # document viewer
  gnome-characters
  gnome-music
  gnome-photos
  gnome-terminal
]);
