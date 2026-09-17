{ pkgs, ... }:
let
  tfa2 = pkgs.callPackage ../pkgs/2fa.nix { };
in
{
  # Misc leftovers that do not belong to a role module yet.
  home.packages = with pkgs; [
    bemoji
    gh
    grimblast
    gvfs
    ipset
    jq
    libnotify
    ntfs3g
    openssl
    p7zip
    pciutils
    rar
    sops
    squashfsTools
    udisks2
    unzip
    w3m
    yazi
    zip
    gvfs
    jmtpfs
    tfa2
  ];
}
