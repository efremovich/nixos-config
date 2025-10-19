{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Desktop apps
    anydesk
    dbeaver-bin
    imv
    insomnia
    kicad
    libreoffice
    mpv
    obsidian
    pavucontrol
    telegram-desktop

    # CLI utils
    bc
    brightnessctl
    cliphist
    ffmpeg
    ffmpegthumbnailer
    freerdp
    fzf
    git-graph
    grimblast
    grpcurl
    gum
    htop
    hyprpicker
    k9s
    kubectl
    mediainfo
    microfetch
    mysql84
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
    lazydocker
    nodejs
    openjdk23
    postgresql
    python311

    # WM stuff
    libnotify
    libsForQt5.xwaylandvideobridge

    # Other
    bemoji
    nix-prefetch-scripts
    nix-search-cli

    pciutils

    gnupg
    jq
    keepassxc
    libxml2
    pass
  ];
}
