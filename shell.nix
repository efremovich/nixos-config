{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [ kicad ];

  shellHook = with pkgs.kicad.passthru.libraries;
    let
      src-footprints = "${footprints}/share/kicad/footprints";
      src-packages3d = "${packages3d}/share/kicad/3dmodels";
      src-symbols = "${symbols}/share/kicad/symbols";
      src-templates = "${templates}/share/kicad/template";
      sym-lib-table = "${symbols}/share/kicad/template/sym-lib-table";
      fp-lib-table = "${footprints}/share/kicad/template/fp-lib-table";
    in ''
      echo ${symbols}
      echo ${footprints}
      export KICAD9_3DMODEL_DIR=~/kicad/3dmodels/
      export KICAD9_FOOTPRINT_DIR=~/kicad/footprints
      export KICAD9_SYMBOL_DIR=~/kicad/symbols
      export KICAD9_TEMPLATE_DIR=~/kicad/template
      mkdir -p ~/kicad
      mkdir -p $KICAD9_3DMODEL_DIR
      mkdir -p $KICAD9_FOOTPRINT_DIR
      mkdir -p $KICAD9_SYMBOL_DIR
      mkdir -p $KICAD9_TEMPLATE_DIR

      cp -r ${src-footprints}/* $KICAD9_FOOTPRINT_DIR
      cp -r ${src-packages3d}/* $KICAD9_3DMODEL_DIR
      cp -r ${src-symbols}/* $KICAD9_SYMBOL_DIR
      cp -r ${src-templates}/* $KICAD9_TEMPLATE_DIR

      cp ${sym-lib-table} $KICAD9_TEMPLATE_DIR
      cp ${fp-lib-table} $KICAD9_TEMPLATE_DIR

      find ~/kicad -type d -exec chmod 755 {} +
      find ~/kicad -type f -exec chmod 644 {} +
    '';
}
