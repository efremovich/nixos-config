{ pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [
    autoconf
    automake
    cargo
    gcc
    gnumake
    libiconv
    libtool
    libxml2
    libxml2.dev
    makeWrapper
    pkg-config
    rustc
    sqlite
    sqlite.dev
    # wireguard
    wireguard-tools
  ];
  environment.variables = {
    PKG_CONFIG_PATH =
      let devPkgs = [ pkgs.sqlite.dev pkgs.libxml2.dev ];
      in lib.concatStringsSep ":" (map (pkg: "${pkg}/lib/pkgconfig") devPkgs);
  };
}
