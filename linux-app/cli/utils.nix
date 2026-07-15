{ pkgs, lib, ... }:
let
  enable = true;
in
lib.mkIf enable {
  home.packages = with pkgs; [
    bc
    git-graph
    gum
    htop
    microfetch
    ripgrep
    sesh
    wget
    wtype
    fd
  ];
}
