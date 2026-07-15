{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # CLI utils
    bc
    git-graph
    grimblast
    gum
    htop
    kubectl
    microfetch
    mysql84
    ntfs3g
    openssl
    rar
    ripgrep
    sesh
    udisks2
    gvfs
    unzip
    w3m
    wget
    wtype
    zip
    p7zip
    fd
    squashfsTools

    libnotify

    # Other
    bemoji
    pciutils
    jq
    libxml2
    ipset
  ];
}
