{
  pkgs,
  inputs,
  lib,
  ...
}:
let
  enable = true;

  pkgsWebkit = import inputs.nixpkgs_22_11 {
    system = pkgs.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [ "libsoup-2.74.3" ];
    };
  };
  webkitGtk = pkgsWebkit.webkitgtk;
  ipCompat = pkgs.runCommand "ip-compat-sbin" { } ''
    mkdir -p "$out/sbin"
    ln -s ${pkgs.iproute2}/bin/ip "$out/sbin/ip"
  '';

  # В FHS-профиле заданы -L/usr/lib, 64-битные .so — в /usr/lib64.
  onecstartInner = pkgs.writeShellScriptBin "1cestart-inner" ''
    export LD_LIBRARY_PATH="/usr/lib64:/usr/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    exec /opt/1cv8/common/1cestart "$@"
  '';

  onecstart = pkgs.buildFHSEnv {
    name = "1cestart";
    targetPkgs =
      ps:
      (with ps; [
        cups.lib
        zlib
        gtk3
        atk
        at-spi2-atk
        at-spi2-core
        pango
        cairo
        harfbuzz
        gdk-pixbuf
        glib
        libepoxy
        libunwind
        xorg.libX11
        xorg.libXxf86vm
        xorg.libSM
        xorg.libXext
        libGL
        libGLU
        dbus
        iproute2
        nss
        nspr
        libsoup_2_4
        webkitGtk
      ])
      ++ [ ipCompat ];
    runScript = "${onecstartInner}/bin/1cestart-inner";
  };

in
lib.mkIf enable {
  home.packages = [
    onecstart
  ];
}
