let colors = (import ./colors.nix).catppuccin-mocha;
in {
  programs.swaylock = {
    enable = true;
    package = null;
    # settings = {
    #   color = "282828";
    #   font = "JetBrains Mono";
    #   font-size = 24;
    #   indicator-idle-visible = true;
    #   indicator-radius = 100;
    #   show-failed-attempts = true;
    # };
  };
}
