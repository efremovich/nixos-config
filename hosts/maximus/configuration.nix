{
  pkgs,
  stateVersion,
  hostname,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./local-packages.nix
    ../../nixos/modules
    ../../nixos/boot/systemd-boot.nix
  ];

  environment.systemPackages = [ pkgs.home-manager ];

  services.hasp.enable = true;

  networking.hostName = hostname;

  system.stateVersion = stateVersion;
}
