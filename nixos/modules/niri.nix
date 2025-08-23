{ inputs, ... }: {
  imports = [ inputs.niri.nixosModules.niri ];

  programs.niri = {
    enable = true;
    package =
      inputs.niri-stable.packages.x86_64-linux.niri-stable; # Use stable Niri
  };

  niri-flake.cache.enable = false; # Opt out of niri.cachix.org

  # Ensure SDDM is used instead of GDM for consistency with Hyprland
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.enable = true;

  # PAM for screen lockers (e.g., hyprlock or a Niri-compatible locker)
  security.pam.services.hyprlock = { };
}
