{
  programs.niri.settings = {
    # Output configuration
    outputs."eDP-1".scale = 2.0;

    # Basic keybindings
    binds = {
      "Mod+T".action.spawn = "alacritty";
      "Mod+D".action.spawn = "fuzzel";
      "Mod+Q".action.close-window = [ ];
    };

    # Startup applications
    spawn-at-startup =
      [ { command = [ "waybar" ]; } { command = [ "mako" ]; } ];
  };
}
