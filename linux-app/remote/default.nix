{ pkgs, lib, ... }:
let
  enable = true;
in
lib.mkIf enable {
  home.packages = with pkgs; [
    freerdp
    anydesk
    minicom
    openvpn3
  ];
}
