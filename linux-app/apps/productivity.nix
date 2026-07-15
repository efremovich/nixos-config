{ pkgs, lib, ... }:
let
  enable = true;
in
lib.mkIf enable {
  home.packages = with pkgs; [
    dbeaver-bin
    insomnia
    libreoffice
    deluge
    inkscape
    zed-editor
    opencode
    keepassxc
    file-roller
    pass
  ];
}
