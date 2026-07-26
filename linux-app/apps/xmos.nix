{ pkgs, lib, ... }:
let
  enable = true;

  xmosFhs = pkgs.buildFHSEnv {
    name = "xmos-fhs";
    targetPkgs =
      ps: with ps; [
        bashInteractive
        coreutils
        findutils
        gnumake
        gnused
        gawk
        gnugrep
        which
        file
        less
        zlib
        ncurses
        # xgdb/xrun: libcrypt.so.1 (glibc больше не кладёт)
        libxcrypt-legacy
        stdenv.cc.cc.lib
        gcc
        binutils
        libusb1
        udev
        systemd
        python3
        xorg.libX11
        xorg.libXext
        xorg.libXrender
        xorg.libXi
        xorg.libXtst
        libGL
        glib
        dbus
      ];
    profile = ''
      source_xmos_setenv() {
        if [ -n "''${XMOS_ENV_READY:-}" ]; then
          return 0
        fi
        local setenv="" root="" oldpwd="$PWD"
        if [ -n "''${XMOS_TOOL_PATH:-}" ] && [ -f "$XMOS_TOOL_PATH/SetEnv" ]; then
          setenv="$XMOS_TOOL_PATH/SetEnv"
        else
          for root in "$HOME/Dev/Xmosi/XMOS/XTC" "$HOME/XMOS/XTC"; do
            if [ -d "$root" ]; then
              local latest
              latest="$(ls -1d "$root"/*/ 2>/dev/null | sort -V | tail -n1 || true)"
              if [ -n "$latest" ] && [ -f "''${latest}SetEnv" ]; then
                setenv="''${latest}SetEnv"
                break
              fi
            fi
          done
        fi
        if [ -n "$setenv" ]; then
          # SetEnv задаёт XMOS_TOOL_PATH=$PWD — нужен каталог тулчейна
          cd "$(dirname "$setenv")" || return 1
          # shellcheck disable=SC1091
          source ./SetEnv
          cd "$oldpwd" || true
          # SetEnv ставит LD_LIBRARY_PATH=tools/lib первым; из‑за этого
          # libtinfo.so.6 (symlink→libncursesw) и системные .so не находятся.
          # Системные пути FHS должны быть первыми.
          export LD_LIBRARY_PATH="/usr/lib64:/usr/lib:/lib64:/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
          export XMOS_ENV_READY=1
          echo "XMOS: sourced $setenv (XMOS_TOOL_PATH=$XMOS_TOOL_PATH)"
          command -v xcc >/dev/null && xcc --version | head -n1 || true
        else
          echo "XMOS: SetEnv не найден."
          echo "  Ожидается: ~/Dev/Xmosi/XMOS/XTC/<version>/SetEnv"
          echo "  или ~/XMOS/XTC/<version>/SetEnv / XMOS_TOOL_PATH=..."
          echo "  См. ~/Dev/Xmosi/scripts/install-xtc.md"
        fi
      }
      source_xmos_setenv
      export PS1="(xmos-fhs) $PS1"
    '';
    runScript = "bash";
  };
in
lib.mkIf enable {
  home.packages = [ xmosFhs ];
}
