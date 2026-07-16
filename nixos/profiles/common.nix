# Shared settings for every host (hostname/stateVersion from flake specialArgs).
{ hostname, stateVersion, ... }:
{
  networking.hostName = hostname;
  system.stateVersion = stateVersion;
}
