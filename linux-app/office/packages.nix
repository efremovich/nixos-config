{ pkgs, lib, ... }:
let
  enable = true;
in
lib.mkIf enable {
  home.packages = with pkgs; [
    libreoffice
    file-roller
    inkscape
  ];
}
