# https://cursor.com/download — pinned official AppImage (not outdated pkgs.code-cursor)
{ pkgs, lib, ... }:
let
  enable = true;
  cursor = pkgs.callPackage ./cursor/package.nix { };
in
lib.mkIf enable {
  home.packages = [ cursor ];
}
