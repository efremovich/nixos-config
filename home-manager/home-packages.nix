{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Desktop apps
    anydesk
    dbeaver-bin
    imv
    insomnia
   # kicad
    libreoffice
    mpv
    obsidian
    pavucontrol
    telegram-desktop
   # google-chrome
    deluge
    inkscape

    #3D print
    freecad
   # orca-slicer
    squashfsTools
   # blender

    # CLI utils
    ast-grep
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
    udisks2
    gvfs
    ueberzugpp
    unzip
    w3m
    wget
    wl-clipboard
    wtype
    yt-dlp
    zip
    fd

    # Coding stuff
    go
    lazydocker
    nodejs
    openjdk25
    postgresql
    statix
    luarocks
    lua51Packages.lua
    graphviz
    protobuf
    natscli
    code-cursor

    # MCP
    platformio
    python3
    python3Packages.pip
    python3Packages.setuptools
    python3Packages.virtualenv
    minicom

    # WM stuff
    libnotify

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
    ipset

    #LLM

  ];
}
