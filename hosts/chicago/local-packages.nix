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
    pkg-config
    rustc
  ];

}
