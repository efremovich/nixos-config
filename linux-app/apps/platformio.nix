{ pkgs, lib, ... }:
let
  enable = true;
in
lib.mkIf enable {
  home.packages = [ pkgs.platformio ];
}
