{ pkgs ? import <nixpkgs> { } }:

# Dev shell for PlatformIO / embedded. KiCad libraries come from pkgs.kicad
# itself (see linux-app/apps/kicad.nix) — do not copy them into ~/kicad.
pkgs.mkShell {
  buildInputs = with pkgs; [
    platformio
    python3
    python3Packages.pip
    python3Packages.setuptools
  ];

  shellHook = ''
    echo "Setting up PlatformIO environment..."
    export PYTHONPATH="${pkgs.python3Packages.pip}/${pkgs.python3.sitePackages}"
  '';
}
