{ pkgs, ... }:
{
  home.packages = with pkgs; [
    libreoffice
    file-roller
  ];
}
