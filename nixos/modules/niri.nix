{ inputs, pkgs, ... }: {
  imports = [ inputs.niri.nixosModules.niri ];

  programs.niri.enable = true;
  programs.niri.package = pkgs.niri-unstable;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
