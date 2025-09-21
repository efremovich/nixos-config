{ inputs, ... }: {
  imports = [ inputs.niri.nixosModules.niri ];

  programs.niri.enable = true;

  services.xserver = { displayManager.gdm.enable = true; };

}
