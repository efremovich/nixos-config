# Stylix theme comes from nixos/modules/stylix.nix (NixOS module + HM autoImport).
# Only HM-specific targets and extra fonts live here — no nixpkgs.* options.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
    noto-fonts-color-emoji
    monaspace
  ];

}
