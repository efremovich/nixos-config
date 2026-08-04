# Тяжёлые CAD-пакеты. kicad.nix подключается отдельно в apps/default.nix.
{ pkgs, lib, ... }:
let
  enable = false;
in
{
  config = lib.mkIf enable {
    home.packages = with pkgs; [
      freecad
      orca-slicer
    ];
  };
}
