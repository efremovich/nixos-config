{ pkgs, ... }:
{
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
    kubectl
    dbeaver-bin
  ];
}
