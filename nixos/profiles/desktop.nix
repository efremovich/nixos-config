# Desktop role: compositor + portals. Services (docker, VPN, HASP) → hosts/*/host.nix.
{
  programs.niri.enable = true;
  xdg.portal.enable = true;
}
