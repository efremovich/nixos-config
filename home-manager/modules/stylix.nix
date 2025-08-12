{ pkgs, inputs, ... }: {
  imports = [ inputs.stylix.homeModules.stylix ];

  home.packages = with pkgs; [
    dejavu_fonts
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-lgc-plus
    texlivePackages.hebrew-fonts
    noto-fonts-emoji
    font-awesome
    powerline-fonts
    powerline-symbols
    nerd-fonts.symbols-only
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

    };

    cursor = {
      name = "DMZ-Black";
      size = 24;
      package = pkgs.vanilla-dmz;
    };

    fonts = {
      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-color-emoji;
      };
      monospace = {
        name = "JetBrains Mono";
        package = pkgs.nerd-fonts.jetbrains-mono;
      };
      sansSerif = {
        name = "Noto Sans";
        package = pkgs.noto-fonts;
      };
      serif = {
        name = "Noto Serif";
        package = pkgs.noto-fonts;
      };

      sizes = {
        terminal = 13;
        applications = 11;
      };
    };

    iconTheme = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };

    image = pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/7j/wallhaven-7j3lve.png";
      sha256 = "kko5Uiq7H0DqiT2aDYbaQCNRzs+5AleaATzsXi3xgQA=";
    };
  };
}
