{ inputs, ... }: {
  # imports = [ inputs.niri.nixosModules.niri ];

  programs.niri.enable = true;

  services = { displayManager.gdm.enable = true; };

}
