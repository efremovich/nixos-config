{ pkgs, inputs, ... }: {
  imports = [ inputs.stylix.homeModules.stylix ];

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

  stylix = {
    enable = true;
    polarity = "light";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-latte.yaml";

    targets = {
      firefox.profileNames = [ "default" ];
      waybar.enable = false;
      wofi.enable = false;
      hyprland.enable = false;
      hyprlock.enable = false;
      neovim.enable = false;
      gtk.enable = true;
      fuzzel.enable = true;
      k9s.enable = true;
      swaync.enable = false;
      swaylock.enable = false;
    };

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

    iconTheme = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };

  };
}
