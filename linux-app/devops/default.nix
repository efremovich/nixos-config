{ pkgs, lib, ... }:
let
  enable = true;
in
lib.mkIf enable {
  home.packages = with pkgs; [
    go
    nodejs
    openjdk25
    postgresql
    luarocks
    lua51Packages.lua
    graphviz
    protobuf
    natscli
    grpcurl
    ast-grep
    lazydocker
    podman
    kubectl
    dbeaver-bin
    insomnia
  ];
}
