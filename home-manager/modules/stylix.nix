{ pkgs, inputs, ... }: {
  imports = [ inputs.stylix.homeModules.stylix ];

  home.packages = with pkgs; [
    nerd-fonts.symbols-only
    nerd-fonts.fira-code
    nerd-fonts.victor-mono
    nerd-fonts.fantasque-sans-mono
    nerd-fonts.caskaydia-cove
    lilex
    font-awesome
    noto-fonts
    noto-fonts-emoji
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
        package = pkgs.jetbrains-mono;
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
