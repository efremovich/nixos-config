{ inputs, ... }: {
  imports = [ inputs.niri.nixosModules.niri ];

  programs.niri.enable = true;

  services.xserver = { displayManager.gdm.enable = true; };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # XDG_CURRENT_DESKTOP = "sway";
    # XDG_SESSION_TYPE = "wayland";
    # XDG_SESSION_DESKTOP = "Hyprland";
    # QT_QPA_PLATFORM = "wayland";
  };
}
