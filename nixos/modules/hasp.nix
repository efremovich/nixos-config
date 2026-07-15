{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.hasp;
  driverUrl = "https://erim.ru/pub/hasp/drivers/linux/Sentinel_LDK_Linux_Run-time_Installer_script.tar.gz";
  driverSrc = pkgs.fetchurl {
    url = driverUrl;
    hash = cfg.driverHash;
  };
in
{
  options.services.hasp = {
    enable = lib.mkEnableOption "HASP runtime and nethasp.ini setup for 1C";

    serverAddress = lib.mkOption {
      type = lib.types.str;
      default = "37.233.80.214";
      description = "IP address of HASP License Manager server.";
    };

    driverHash = lib.mkOption {
      type = lib.types.str;
      # Prefetch: nix-prefetch-url --type sha256 <url> && nix hash to-sri --type sha256 <base32>
      default = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      description = "SRI hash of the Sentinel LDK runtime installer tarball.";
    };
  };

  config = lib.mkIf cfg.enable {
    system.activationScripts.nethaspIni = {
      deps = [
        "users"
        "groups"
      ];
      text = ''
                install -d -m 0755 /opt/1cv8/conf
                cat > /opt/1cv8/conf/nethasp.ini <<'EOF'
        [NH_COMMON]
        NH_TCPIP = Enabled

        [NH_TCPIP]
        NH_SERVER_ADDR = ${cfg.serverAddress}
        NH_USE_BROADCAST = Disabled
        EOF
      '';
    };

    systemd.services.hasp-runtime-install = {
      description = "Install Sentinel HASP runtime from Nix store";
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
        gnutar
        gzip
        findutils
      ];
      script = ''
        set -euo pipefail

        # Проверяем, установлен ли уже драйвер
        if command -v hasplmd >/dev/null 2>&1 || [ -x /etc/init.d/aksusbd ] || systemctl is-active --quiet aksusbd 2>/dev/null; then
          echo "HASP runtime already installed, skipping installation."
          exit 0
        fi

        workdir="$(mktemp -d)"
        trap 'rm -rf "$workdir"' EXIT

        echo "Extracting HASP runtime from ${driverSrc}..."
        tar -xzf "${driverSrc}" -C "$workdir"

        # Находим директорию с инсталлятором
        installer_dir="$(find "$workdir" -maxdepth 1 -type d -name 'Sentinel_LDK_*' | head -n 1)"
        if [ -z "$installer_dir" ]; then
          echo "Cannot find Sentinel_LDK_* directory" >&2
          exit 1
        fi

        # Распаковываем вложенный архив aksusbd
        cd "$installer_dir"
        aksusbd_archive="$(find . -maxdepth 1 -name 'aksusbd-*.tar.gz' | head -n 1)"
        if [ -z "$aksusbd_archive" ]; then
          echo "Cannot find aksusbd-*.tar.gz archive" >&2
          exit 1
        fi

        echo "Extracting $aksusbd_archive..."
        tar -xzf "$aksusbd_archive"

        # Находим распакованную директорию aksusbd
        dir="$(find . -maxdepth 1 -type d -name 'aksusbd-*' | head -n 1)"
        if [ -z "$dir" ]; then
          echo "Cannot find extracted aksusbd-* directory" >&2
          exit 1
        fi

        cd "$dir"

        # Vendor installer uses /bin/bash shebangs; patch for NixOS layout.
        while IFS= read -r -d "" f; do
          first_line="$(head -n 1 "$f" || true)"
          if [ "$first_line" = "#!/bin/bash" ]; then
            sed -i "1 s|^#!/bin/bash$|#!${pkgs.bash}/bin/bash|" "$f"
          fi
        done < <(find "$dir" -type f -print0)

        chmod +x ./dinst
        echo "Running installer..."
        ${pkgs.bash}/bin/bash ./dinst
      '';
    };
  };
}
