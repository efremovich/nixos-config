{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.hasp;
in
{
  options.services.hasp = {
    enable = lib.mkEnableOption "HASP runtime and nethasp.ini setup for 1C";

    serverAddress = lib.mkOption {
      type = lib.types.str;
      default = "51.254.148.241";
      description = "IP address of HASP License Manager server.";
    };

    runtimeArchive = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/var/lib/hasp/aksusbd-10.12.1.tar.gz";
      description = ''
        Path to Sentinel LDK Runtime archive (aksusbd-*.tar.gz).
        If set, a one-shot service installs runtime by running ./dinst.
      '';
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

    systemd.services.hasp-runtime-install = lib.mkIf (cfg.runtimeArchive != null) {
      description = "Install Sentinel HASP runtime from archive";
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

        if command -v hasplmd >/dev/null 2>&1 || [ -x /etc/init.d/aksusbd ]; then
          exit 0
        fi

        if [ ! -f "${cfg.runtimeArchive}" ]; then
          echo "HASP runtime archive not found: ${cfg.runtimeArchive}" >&2
          exit 1
        fi

        workdir="$(mktemp -d)"
        trap 'rm -rf "$workdir"' EXIT

        tar -xzf "${cfg.runtimeArchive}" -C "$workdir"
        dir="$(find "$workdir" -maxdepth 1 -type d -name 'aksusbd-*' | head -n 1)"

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
        ${pkgs.bash}/bin/bash ./dinst
      '';
    };
  };
}
