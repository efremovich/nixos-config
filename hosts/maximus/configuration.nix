{
  imports = [
    ./hardware-configuration.nix
    ./host.nix
    ../../nixos/modules
    ../../nixos/boot/systemd-boot.nix
  ];
}
