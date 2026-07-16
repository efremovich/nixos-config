{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        # Show entries regardless of OnlyShowIn / XDG_CURRENT_DESKTOP=niri.
        filter-desktop = false;
      };
    };
  };
}
