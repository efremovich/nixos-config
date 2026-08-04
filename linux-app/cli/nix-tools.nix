{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nixpkgs-fmt
    nix-prefetch-scripts
    nix-search-cli
    statix
  ];
}
