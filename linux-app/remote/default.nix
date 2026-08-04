{ pkgs, ... }:
{
  home.packages = with pkgs; [
    freerdp
    anydesk
    minicom
    openvpn3
  ];
}
