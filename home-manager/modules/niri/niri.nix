{
  programs.niri = {
    enable = true;
    settings = {
      input = {
        keyboard = {
          xkb = {
            layout = "en,ru";
            options = "grp:caps_toggle";
          };
        };
      };
    };
  };
}
