{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    #niri
    niri
    swaylock
    swayidle
    swaybg
    fuzzel

    # Desktop apps
    dbeaver-bin
    imv
    # kicad
    libreoffice
    mpv
    # obsidian
    pavucontrol
    telegram-desktop
    # yandex-music
    anydesk

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
    htop
    hyprpicker
    mediainfo
    microfetch
    nixpkgs-fmt
    ntfs3g
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
    rar
    zip
    freerdp
    k9s
    kubectl
    openssl
    grpcurl

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
    qt6.qtwayland
    libsForQt5.qt5.qtwayland
    # xdg-desktop-portal-gtk
    # xdg-desktop-portal-hyprland

    nekoray
    # Other
    bemoji
    nix-prefetch-scripts

    swaylock
    swayidle
    niri

    pciutils
    remmina

    nix-search-cli
    libxml2
    jq
    # v2raya
    pass
    gnupg
    keepassxc
  ];
}
