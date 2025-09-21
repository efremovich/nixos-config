{ pkgs, ... }: {
  imports = [ ./services.nix ./swaylock.nix ./xwayland-satellite.nix ];

  home.packages = with pkgs; [
    swww
    swaybg
    swaynotificationcenter
    wl-clipboard
    wlr-which-key
    cliphist
    wl-clip-persist
    wlogout
    libinput
    networkmanagerapplet
    pavucontrol
    playerctl
    pipewire
    hyprpicker
    python312Packages.toggl-cli
    grim
    slurp
    swappy
  ];

  services.hyprpaper = { enable = true; };

  home.file.".config/niri" = {
    recursive = true;
    source = ./niri;
  };

  home.file.".config/swaync" = {
    recursive = true;
    source = ./swaync;
  };

  home.file.".config/wlr-which-key" = {
    recursive = true;
    source = ./wlr-which-key;
  };

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # XDG_CURRENT_DESKTOP = "sway";
    # XDG_SESSION_TYPE = "wayland";
    # XDG_SESSION_DESKTOP = "Hyprland";
    # QT_QPA_PLATFORM = "wayland";
  };
}
