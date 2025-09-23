{ pkgs, inputs, ... }: {
  imports = [ ./services.nix ./swaylock.nix ./xwayland-satellite.nix ];

  home.packages = with pkgs; [
    cliphist
    grim
    hyprpicker
    libinput
    networkmanagerapplet
    pavucontrol
    pipewire
    playerctl
    python312Packages.toggl-cli
    slurp
    swappy
    swaybg
    swaylock
    swayidle
    swaynotificationcenter
    swww
    wl-clip-persist
    wl-clipboard
    wlogout
    inputs.unstable.legacyPackages.${pkgs.system}.wlr-which-key
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
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    QT_QPA_PLATFORM = "wayland";
  };
}
