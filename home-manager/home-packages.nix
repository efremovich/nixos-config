{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Desktop apps
    dbeaver-bin
    imv
    # kicad
    libreoffice
    mpv
    obsidian
    pavucontrol
    telegram-desktop
    # yandex-music
    anydesk
    remmina

    # CLI utils
    bc
    brightnessctl
    cliphist
    ffmpeg
    ffmpegthumbnailer
    fzf
    git-graph
    grimblast
    gum
    grpcurl
    htop
    hyprpicker
    k9s
    kubectl
    mediainfo
    microfetch
    nixpkgs-fmt
    ntfs3g
    openssl
    playerctl
    rar
    ripgrep
    sesh
    udisks
    ueberzugpp
    unzip
    w3m
    wget
    wl-clipboard
    wtype
    yt-dlp
    zip

    # Coding stuff
    go
    nodejs
    openjdk23
    python311
    postgresql
    lazydocker

    # WM stuff
    libsForQt5.xwaylandvideobridge
    libnotify
    # qt6.qtwayland
    # libsForQt5.qt5.qtwayland
    # xdg-desktop-portal-gtk
    # xdg-desktop-portal-hyprland

    # Other
    bemoji
    nix-prefetch-scripts
    nix-search-cli

    pciutils

    libxml2
    jq
    pass
    gnupg
    keepassxc
  ];
}
