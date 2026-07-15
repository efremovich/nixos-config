{ pkgs, lib, ... }:
let
  enable = true;
in
lib.mkIf enable {
  home.packages = with pkgs; [
    go
    lazydocker
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
  ];
}
