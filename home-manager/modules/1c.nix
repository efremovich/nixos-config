{ pkgs, inputs, ... }:
let
  # База REST API облака для EDT Start (AuthClientImpl: свойство e1c.dt.cloud.projectService.uri).
  # Пути вроде sec/oauth20/token относительно этого URL. Менять только если поддержка 1С дала другой endpoint.
  #
  # «login.1c.ru» в браузере приходит в теле ответа OAuth с сервера, отдельной JVM-настройки на него нет.
  # Если проблема именно в DNS/маршруте до login.1c.ru — смотрите актуальный IP (`getent hosts login.1c.ru`)
  # и при необходимости зафиксируйте в NixOS: networking.hosts."<IP>" = [ "login.1c.ru" ];
  edtProjectServiceUri = "https://services.1c.dev/setups/v1/";

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

  edtStartInner = pkgs.writeShellScriptBin "1cedtstart-inner" ''
    export LD_LIBRARY_PATH="/usr/lib64:/usr/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    export JAVA_HOME="/opt/1C/1CE/components/axiom-jdk-full-17.0.16+12-x86_64"
    export JRE_HOME="$JAVA_HOME"
    export PATH="$JAVA_HOME/bin:$PATH"
    # Не передавать -vmargs с командной строки: у Eclipse второй -vmargs заменяет vmargs из
    # 1cedtstart.ini целиком и теряются --add-opens для JavaFX → IllegalAccessError в логе.
    # _JAVA_OPTIONS дописывается JVM в конец командной строки и перекрывает -Xmx/-XX из ini.
    # Авторизация: без браузера — логин/пароль Keycloak в окне EDT Start.
    export _JAVA_OPTIONS="-XX:MaxDirectMemorySize=512m -Xmx1024m -Xms256m -De1c.dt.cloud.launcher.auth.useDirect=false -De1c.dt.cloud.launcher.auth.useOAuth=true -De1c.dt.cloud.projectService.uri=${edtProjectServiceUri}"
    # В логе UrlCommandHandler ругался на @user.home в -eclipse.keyring — подставляем реальный путь.
    mkdir -p "''${HOME}/.eclipse/com.e1c.g5.dt.cloud.start"
    exec /opt/1C/1CE/components/1c-edt-start-0.9.0+229-x86_64/1cedtstart -vm "$JAVA_HOME/bin/java" \
      -eclipse.keyring "''${HOME}/.eclipse/com.e1c.g5.dt.cloud.start/secure_storage" \
      "$@"
  '';

  edtstart = pkgs.buildFHSEnv {
    name = "1cedtstart";
    targetPkgs =
      ps:
      (with ps; [
        stdenv.cc.cc.lib
        zlib
        glib
        gtk3
        gdk-pixbuf
        pango
        cairo
        atk
        at-spi2-atk
        at-spi2-core
        dbus
        nss
        nspr
        expat
        libdrm
        mesa
        alsa-lib
        cups.lib
        xorg.libX11
        xorg.libXext
        xorg.libXi
        xorg.libXrender
        xorg.libXrandr
        xorg.libXcursor
        xorg.libXinerama
        xorg.libXcomposite
        xorg.libXdamage
        xorg.libXfixes
        xorg.libXtst
        xorg.libxcb
        xorg.libXxf86vm
      ]);
    runScript = "${edtStartInner}/bin/1cedtstart-inner";
  };
in
{
  nixpkgs.config.permittedInsecurePackages = [
    "libsoup-2.74.3"
  ];

  home.packages = [
    onecstart
    edtstart
  ];
}
