{ pkgs, lib, ... }:
let
  enable = false;
in
lib.mkIf enable {
  home.packages = [ pkgs.google-chrome ];
}
