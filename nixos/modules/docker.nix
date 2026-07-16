{ lib, config, ... }:
{
  config = lib.mkIf config.virtualisation.docker.enable {
    services.resolved.enable = true;
  };
}
