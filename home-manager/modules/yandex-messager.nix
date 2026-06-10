{ pkgs, ... }:
let
  inherit (pkgs)
    stdenv
    lib
    fetchurl
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
    makeWrapper
    alsa-lib
    at-spi2-core
    gtk3
    libappindicator-gtk3
    libdrm
    libgbm
    libnotify
    libsecret
    nspr
    nss
    systemd
    xorg
    ;

  yandexMessenger = stdenv.mkDerivation rec {
    pname = "yandex-messenger";
    version = "2.155.0";

    src = fetchurl {
      url = "https://downloader.disk.yandex.ru/disk/b120825a2285933b86ea04b463dfae7008f01c0981be6ddb4fd0b6daca8bcd71/6a297bf2/fKqInKw3d7bLFOeFnMGnhNWxCpe349obSYmly8cW7zZJ_fniSbaCrlwjQTbvB92IUPUnXitKQ2ltyzIVVtHF0RfdGUpZH039231ae3iQvySr8npumZHI4midPdWhecNq?uid=0&filename=Yandex_Messenger_2.155.0_amd64.deb&disposition=attachment&hash=7bGpeID6q904ZsjE4/ehCmxnCtN1OkUIf5Iszu%2B0hU8Gu1h8chTxFpPyI2je%2BlPrlsg4VIaLrfRKbQetv4dueQ%3D%3D%3A&limit=0&content_type=application%2Fvnd.debian.binary-package&owner_uid=1130000063429726&fsize=73548980&hid=d833151ad80ffb273b072a7a34c673d9&media_type=compressed&tknv=v3&is_direct_zip_experiment=1";
      name = "Yandex_Messenger_${version}_amd64.deb";
      hash = "sha256-vGb6csJ7M09DYFXiUK4mmzAM28FnIl3GM/rKkGm/Xco=";
    };

    nativeBuildInputs = [
      dpkg
      autoPatchelfHook
      wrapGAppsHook3
      makeWrapper
    ];

    buildInputs = [
      alsa-lib
      gtk3
      libdrm
      libgbm
      libnotify
      libsecret
      nspr
      nss
      systemd
      at-spi2-core
      libappindicator-gtk3
    ]
    ++ (with xorg; [
      libXScrnSaver
      libXtst
      libX11
      libXcomposite
      libXdamage
      libXext
      libXfixes
      libXi
      libXrandr
      libXrender
      libxcb
    ]);

    dontBuild = true;
    dontConfigure = true;
    dontWrapGApps = true;

    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x $src .
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/bin"
      cp -R opt "$out/"
      cp -R usr/share "$out/share"

      substituteInPlace "$out/share/applications/chats.desktop" \
        --replace-fail '"/opt/Yandex Messenger/chats"' "yandex-messenger"

      runHook postInstall
    '';

    runtimeDependencies = [
      (lib.getLib systemd)
    ];

    preFixup = ''
      gappsWrapperArgs+=(--add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}")
    '';

    postFixup = ''
      makeWrapper "$out/opt/Yandex Messenger/chats" "$out/bin/yandex-messenger" \
        "''${gappsWrapperArgs[@]}"
    '';

    meta = with lib; {
      description = "Yandex Messenger desktop client";
      homepage = "https://yandex.com/support/messenger/install.html";
      license = licenses.unfree;
      sourceProvenance = with sourceTypes; [ binaryNativeCode ];
      platforms = [ "x86_64-linux" ];
      mainProgram = "yandex-messenger";
    };
  };
in
{
  home.packages = [ yandexMessenger ];
}
