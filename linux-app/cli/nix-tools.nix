{ pkgs, lib, ... }:
let
  enable = true;
in
lib.mkIf enable {
  home.packages = with pkgs; [
    nixpkgs-fmt
    nix-prefetch-scripts
    nix-search-cli
    statix
  ];
}
