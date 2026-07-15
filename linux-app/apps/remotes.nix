{ pkgs, lib, ... }:
let
  enable = true;
in
lib.mkIf enable {
  home.packages = with pkgs; [
    freerdp
    minicom
    openvpn3
    podman
  ];
}
