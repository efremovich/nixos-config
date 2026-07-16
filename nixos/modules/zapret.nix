# Enable from host: services.zapret.enable = true;
{ lib, pkgs, config, ... }:
{
  config = lib.mkIf config.services.zapret.enable {
    services.zapret = {
      package = pkgs.zapret;

      udpSupport = true;
      udpPorts = [
        "443"
        "50000:65535"
      ];

      whitelist = [ "youtube.com" ];

      params = [
        "--dpi-desync=fake"
        "--dpi-desync-fooling=badseq"
        "--dpi-desync-fake-tls=0x00000000"
      ];
    };
  };
}
