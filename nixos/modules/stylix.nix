{ pkgs, inputs, ... }:
{
  imports = [ inputs.stylix.nixosModules.stylix ];

  # With home-manager.useGlobalPkgs, Stylix disables HM nixpkgs.overlays automatically.
  stylix = {
    enable = true;
    polarity = "light";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-latte.yaml";

    cursor = {
      name = "Bibata-Original-Ice";
      size = 24;
      package = pkgs.bibata-cursors;
    };

    fonts = {
      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-color-emoji;
      };
      monospace = {
        name = "CaskaydiaCoveNerdFontPropo";
        package = pkgs.cascadia-code;
      };
      sansSerif = {
        name = "Noto Sans";
        package = pkgs.nerd-fonts.noto;
      };
      serif = {
        name = "Noto Serif";
        package = pkgs.nerd-fonts.noto;
      };

      sizes = {
        terminal = 13;
        applications = 12;
      };
    };

    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };
  };
}
