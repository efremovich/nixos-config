# Stylix theme comes from nixos/modules/stylix.nix (NixOS module + HM autoImport).
# Only HM-specific targets and extra fonts live here — no nixpkgs.* options.
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nerd-fonts.symbols-only
    nerd-fonts.fira-code
    nerd-fonts.victor-mono
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.caskaydia-cove
    nerd-fonts.jetbrains-mono
    lilex
    font-awesome
    noto-fonts
    noto-fonts-color-emoji
    recursive
    sn-pro
    ia-writer-quattro
    ia-writer-duospace
    libre-baskerville
    monaspace
    maple-mono.NF
    maple-mono.variable
  ];

  stylix.targets = {
    firefox.profileNames = [ "default" ];
    waybar.enable = false;
    neovim.enable = false;
    gtk.enable = true;
    fuzzel.enable = true;
    k9s.enable = true;
    mako.enable = false;
    swaync.enable = false;
    swaylock.enable = false;
  };
}
