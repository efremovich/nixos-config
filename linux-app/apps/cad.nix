{ pkgs, lib, ... }:
let
  enable = true;
in
{
  imports = [ ./kicad.nix ];

  config = lib.mkIf enable {
    home.packages = with pkgs; [
      freecad
      orca-slicer
    ];
  };
}
