{ pkgs, ... }:
{
  # Host-specific extras (common toolchain is in nixos/modules/devtools.nix).
  environment.systemPackages = with pkgs; [
    wireguard-tools
  ];
}
