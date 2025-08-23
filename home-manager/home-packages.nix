{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Packages in each category are sorted alphabetically

    # Desktop apps
    dbeaver-bin
    imv
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
    showmethekey
    silicon
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

    # Coding stuff
    go
    nodejs
    openjdk23
    python311

    # WM stuff
    libsForQt5.xwaylandvideobridge
    libnotify
    # xdg-desktop-portal-gtk
    # xdg-desktop-portal-wlr
    # xdg-desktop-portal-gnome

    # Other
    bemoji
    nix-prefetch-scripts

    swaylock
    swayidle
    niri
  ];
}
