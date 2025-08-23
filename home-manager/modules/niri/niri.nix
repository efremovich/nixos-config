{
  programs.niri = {
    enable = true;
    settings = {
      input = {
        keyboard = {
          xkb = {
            layout = "us,ru";
            options = "grp:caps_toggle";
          };
        };
        touchpad = {
          tap = true;
          natural-scroll = true;
        };
      };
    };
    environment = {
      "NIXOS_OZONE_WL" = "1";
      "XDG_CURRENT_DESKTOP" = "niri";
      "XDG_SESSION_TYPE" = "wayland";
      "XDG_SESSION_DESKTOP" = "niri";
      "QT_QPA_PLATFORM" = "wayland";
    };

    window-rules = [
      {
        match = { app-id = "obsidian"; };
        default-workspace = 3;
      }
      {
        match = { app-id = "zathura"; };
        default-workspace = 3;
      }
      {
        match = { app-id = "com.obsproject.Studio"; };
        default-workspace = 4;
      }
      {
        match = { app-id = "telegram"; };
        default-workspace = 5;
      }
      {
        match = { app-id = "vesktop"; };
        default-workspace = 5;
      }
      {
        match = { app-id = "teams-for-linux"; };
        default-workspace = 6;
      }
    ];

    startup = [
      { command = "waybar"; }
      { command = "wl-paste --type text --watch cliphist store"; }
      { command = "wl-paste --type image --watch cliphist store"; }
      { command = "swaync"; }
    ];
  };
}
