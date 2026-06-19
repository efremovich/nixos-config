{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.ideco;
  installerUrl = "https://91.239.5.9/lk/IdecoClient.sh";
  installDir = "/usr/local/Ideco/Agent";
  bashPath = "${pkgs.bash}/bin/bash";

  clientWrapper = pkgs.writeShellScript "IdecoClient.sh" ''
    APP_DIR="$(dirname "$(readlink -f "$0")")"
    exec "$APP_DIR/ld.so" --argv0 IdecoClient --library-path "$APP_DIR/lib" "$APP_DIR/IdecoClient" "$@"
  '';

  serviceWrapper = pkgs.writeShellScript "IdecoService.sh" ''
    APP_DIR="$(dirname "$(readlink -f "$0")")"
    exec "$APP_DIR/ld.so" --argv0 IdecoService --library-path "$APP_DIR/lib" "$APP_DIR/IdecoService" "$@"
  '';
in
{
  options.services.ideco = {
    enable = lib.mkEnableOption "Ideco Client (VPN/ZTNA agent)";
  };

  config = lib.mkIf cfg.enable {
    systemd.services.ideco-install = {
      description = "Download and install Ideco Client";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      path = with pkgs; [
        bash
        coreutils
        curl
        findutils
        gnugrep
        gnused
        gnutar
        gzip
        util-linux
      ];
      script = ''
        set -euo pipefail

        latest=""
        if [ -d "${installDir}" ]; then
          latest="$(ls -1d ${installDir}/*/ 2>/dev/null | sort -V | tail -1 || true)"
        fi
        if [ -n "$latest" ] && [ -x "$latest/IdecoService" ]; then
          echo "IdecoClient already installed, skipping."
          exit 0
        fi

        workdir="$(mktemp -d)"
        trap 'rm -rf "$workdir"' EXIT

        echo "Downloading IdecoClient installer..."
        curl -k --fail -o "$workdir/installer.sh" "${installerUrl}"
        chmod +x "$workdir/installer.sh"

        echo "Extracting embedded archive..."
        sed '0,/^RAWDATA:$/d' "$workdir/installer.sh" > "$workdir/archive.tar.gz"

        version="$(grep -a '^readonly version=' "$workdir/installer.sh" | cut -d= -f2)"
        if [ -z "$version" ]; then
          echo "Cannot determine version from installer" >&2
          exit 1
        fi

        app_dir="${installDir}/$version"
        temp_dir="$app_dir.tmp"

        mkdir -m 755 -p "$temp_dir"
        tar --no-same-owner -xzf "$workdir/archive.tar.gz" -C "$temp_dir"

        mkdir -p -m 755 "${installDir}"
        rm -rf "$app_dir"
        mv "$temp_dir" "$app_dir"

        cp ${clientWrapper} "$app_dir/IdecoClient.sh"
        chmod 755 "$app_dir/IdecoClient.sh"
        ln -sf "$app_dir/IdecoClient.sh" /usr/local/bin/IdecoClient

        mkdir -p -m 755 /usr/local/share/applications
        printf '%s\n' \
          "[Desktop Entry]" \
          "Version=1.0" \
          "StartupWMClass=Agent" \
          "Type=Application" \
          "Name=Ideco Client" \
          "Exec=$app_dir/ld.so --argv0 IdecoClient --library-path $app_dir/lib $app_dir/IdecoClient --show" \
          "Icon=$app_dir/res/client_logo.svg" \
          "Comment=Ideco Client version $version" \
          "StartupNotify=true" \
          "Terminal=false" \
          "Categories=Network;" \
          "Keywords=Agent;VPN;vpn;ztna;client;ideco;Ideco" \
          > "/usr/local/share/applications/IdecoAgent-$version.desktop"
        chmod 644 "/usr/local/share/applications/IdecoAgent-$version.desktop"

        find "${installDir}" -maxdepth 1 -mindepth 1 -not -name "$version" -exec rm -rf '{}' '+' || true

        echo "IdecoClient $version installed successfully."
      '';
    };

    system.activationScripts.ideco-wrapper = ''
      if [ -d "${installDir}" ]; then
        for vdir in ${installDir}/*/; do
          [ -d "$vdir" ] || continue
          cp ${clientWrapper} "$vdir/IdecoClient.sh"
          chmod 755 "$vdir/IdecoClient.sh"
        done
        mkdir -p /usr/local/bin
        latest="$(ls -1d ${installDir}/*/ 2>/dev/null | sort -V | tail -1 || true)"
        if [ -n "$latest" ]; then
          ln -sf "$latest/IdecoClient.sh" /usr/local/bin/IdecoClient
        fi
      fi
      if [ ! -d /usr/lib/locale ] && [ -d /run/current-system/sw/lib/locale ]; then
        mkdir -p /usr/lib
        ln -sfn /run/current-system/sw/lib/locale /usr/lib/locale
      fi
      if [ ! -d /usr/share/X11/xkb ] && [ -d /run/current-system/sw/share/X11/xkb ]; then
        mkdir -p /usr/share/X11
        ln -sfn /run/current-system/sw/share/X11/xkb /usr/share/X11/xkb
      fi
    '';

    security.pki.certificateFiles = [
      ../certs/ideco-root-ca.crt
    ];

    systemd.services.ideco-service = {
      description = "IdecoService";
      after = [ "network.target" "ideco-install.service" ];
      wants = [ "ideco-install.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "notify";
        Restart = "always";
        KillMode = "mixed";
      };
      script = ''
        latest_version="$(ls -1d ${installDir}/*/ 2>/dev/null | sort -V | tail -1 | xargs basename || true)"
        if [ -z "$latest_version" ]; then
          echo "No IdecoClient version found in ${installDir}" >&2
          exit 1
        fi
        exec ${installDir}/$latest_version/ld.so \
          --argv0 IdecoService \
          --library-path ${installDir}/$latest_version/lib \
          ${installDir}/$latest_version/IdecoService
      '';
    };
  };
}
