{ lib, config, pkgs, ... }:
{
  config = lib.mkIf config.virtualisation.docker.enable {
    services.resolved.enable = true;

    # iptables here is the nf_tables backend, and Docker 28+ looks for the
    # `nft` binary to clean up its nftables rules. Without it dockerd logs
    # "Failed to find nft tool: executable file not found in $PATH".
    environment.systemPackages = [ pkgs.nftables ];
  };
}
