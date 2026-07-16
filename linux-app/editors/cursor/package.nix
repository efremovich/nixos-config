# Official Cursor desktop from https://cursor.com/download (AppImage),
# packaged with nixpkgs vscode-generic (same approach as pkgs.code-cursor).
{
  lib,
  stdenv,
  callPackage,
  vscode-generic,
  fetchurl,
  appimageTools,
  commandLineArgs ? "",
  useVSCodeRipgrep ? false,
}:

let
  inherit (stdenv) hostPlatform;
  finalCommandLineArgs = "--update=false " + commandLineArgs;

  sourcesJson = lib.importJSON ./sources.json;
  sources = lib.mapAttrs (
    _: info:
    fetchurl {
      inherit (info) url hash;
    }
  ) sourcesJson.sources;

  source = sources.${hostPlatform.system};
in
(callPackage vscode-generic rec {
  inherit useVSCodeRipgrep;
  inherit (sourcesJson) version vscodeVersion;
  commandLineArgs = finalCommandLineArgs;

  pname = "cursor";

  executableName = "cursor";
  longName = "Cursor";
  shortName = "cursor";
  libraryName = "cursor";
  iconName = "cursor";

  src = appimageTools.extract {
    inherit pname version;
    src = source;
  };

  sourceRoot = "${pname}-${version}-extracted/usr/share/cursor";

  tests = { };
  updateScript = null;

  # Cursor has no wrapper script.
  patchVSCodePath = false;

  meta = {
    description = "AI-powered code editor built on vscode";
    homepage = "https://cursor.com/download";
    changelog = "https://cursor.com/changelog";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "cursor";
  };
})
