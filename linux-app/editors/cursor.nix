# https://cursor.com/download — pinned official AppImage (not outdated pkgs.code-cursor)
{ pkgs, lib, ... }:
let
  enable = true;
  cursor = pkgs.callPackage ./cursor/package.nix {
    vscode-generic = pkgs.path + "/pkgs/applications/editors/vscode/generic.nix";
  };
in
lib.mkIf enable {
  home.packages = [ cursor ];
}
