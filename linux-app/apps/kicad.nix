{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  enable = true;

  pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
in
# Official libs come with pkgsUnstable.kicad; the wrapper exports
# KICAD10_{SYMBOL,FOOTPRINT,3DMODEL,TEMPLATE}_DIR into /nix/store/...
# Do not override those with ~/kicad copies (breaks after GC / upgrades).
lib.mkIf enable {
  home.packages = [ pkgsUnstable.kicad ];

  programs.fish.interactiveShellInit = lib.mkAfter ''
    # Drop obsolete KiCad env from old nix-shell ~/kicad workflow
    set -e KICAD10_SYMBOL_DIR
    set -e KICAD10_FOOTPRINT_DIR
    set -e KICAD10_3DMODEL_DIR
    set -e KICAD10_TEMPLATE_DIR
  '';
}
