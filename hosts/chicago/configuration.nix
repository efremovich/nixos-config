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
    ../../home-manager/modules/kesl.nix
    ../../nixos/boot/grub.nix
    # ../../nixos/desktop
    ../../nixos/graphics/amd.nix
  ];

  environment.systemPackages = [ pkgs.home-manager ];

  services.hasp.enable = true;
  services.ideco.enable = true;
  kesl.enable = true;

  networking.hostName = hostname;

  system.stateVersion = stateVersion;
}
