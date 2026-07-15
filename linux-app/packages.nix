{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Desktop apps
    dbeaver-bin
    imv
    insomnia
    libreoffice
    mpv
    deluge
    inkscape
    zed-editor
    opencode
    squashfsTools

    # CLI utils
    ast-grep
    bc
    ffmpeg
    ffmpegthumbnailer
    freerdp
    git-graph
    grimblast
    grpcurl
    gum
    htop
    kubectl
    mediainfo
    microfetch
    mysql84
    nixpkgs-fmt
    ntfs3g
    openssl
    rar
    ripgrep
    sesh
    udisks2
    gvfs
    ueberzugpp
    unzip
    w3m
    wget
    wtype
    yt-dlp
    zip
    p7zip
    fd
    podman

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

    # MCP / embedded
    platformio
    python3
    python3Packages.pip
    python3Packages.setuptools
    python3Packages.virtualenv
    minicom
    openvpn3

    libnotify

    # Other
    bemoji
    nix-prefetch-scripts
    nix-search-cli
    zsh
    pciutils
    jq
    keepassxc
    libxml2
    pass
    ipset
    file-roller
  ];
}
