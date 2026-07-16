{ pkgs, ... }:
{
  # Misc leftovers that do not belong to a role module yet.
  home.packages = with pkgs; [
    grimblast
    mysql84
    ntfs3g
    openssl
    rar
    udisks2
    gvfs
    unzip
    w3m
    zip
    p7zip
    squashfsTools
    libnotify
    bemoji
    pciutils
    jq
    libxml2
    ipset
  ];
}
