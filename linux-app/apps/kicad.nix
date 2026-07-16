{ pkgs, lib, ... }:
let
  enable = true;
in
# Official libs come with pkgs.kicad; the wrapper exports
# KICAD9_{SYMBOL,FOOTPRINT,3DMODEL,TEMPLATE}_DIR into /nix/store/...
# Do not override those with ~/kicad copies (breaks after GC / upgrades).
lib.mkIf enable {
  home.packages = [ pkgs.kicad ];

  programs.fish.interactiveShellInit = lib.mkAfter ''
    # Drop obsolete KiCad env from old nix-shell ~/kicad workflow
    set -e KICAD9_SYMBOL_DIR
    set -e KICAD9_FOOTPRINT_DIR
    set -e KICAD9_3DMODEL_DIR
    set -e KICAD9_TEMPLATE_DIR
  '';
}
