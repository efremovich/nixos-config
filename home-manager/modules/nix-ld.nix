{
  programs.nix-ld.enable = true;
  # programs.nix-ld.package = pkgs.nix-ld-rs;

  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
    icu
    glib
    libgcc
  ];
}
