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
    ../../nixos/boot/grub.nix
    # ../../nixos/desktop
    ../../nixos/graphics/amd.nix
  ];

  environment.systemPackages = [ pkgs.home-manager ];

  services.hasp = {
    enable = true;
    serverAddress = "51.254.148.241";
    # Положите официальный архив aksusbd-*.tar.gz сюда, затем выполните nixos-rebuild switch.
    runtimeArchive = "/var/lib/hasp/aksusbd-10.12.1.tar.gz";
  };

  networking.hostName = hostname;

  system.stateVersion = stateVersion;
}
