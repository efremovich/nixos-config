let colors = (import ./colors.nix).catppuccin-mocha;
in {
  programs.swaylock = {
    enable = true;
    package = null;
  };
}
