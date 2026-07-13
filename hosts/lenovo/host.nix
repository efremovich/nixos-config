{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    autoconf
    automake
    cargo
    gcc
    gnumake
    libiconv
    libtool
    makeWrapper
    sqlite
    pkg-config
    rustc
    libxml2
  ];

  environment.variables.PKG_CONFIG_PATH = "${pkgs.libxml2.dev}/lib/pkgconfig";
}
