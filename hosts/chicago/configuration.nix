{
  imports = [
    ./hardware-configuration.nix
    ./host.nix
    ../../nixos/modules
    ../../nixos/boot/grub.nix
    ../../nixos/graphics/amd.nix
  ];
}
