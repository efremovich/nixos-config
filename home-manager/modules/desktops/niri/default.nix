{ pkgs, inputs, ... }:
{
  imports = [
    ./services.nix
    ./swaylock.nix
    ./xwayland-satellite.nix
  ];

  # services.hyprpaper = {
  #   enable = true;
  # };

  home = {

    packages = with pkgs; [
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
      wlr-which-key
    ];
    file = {

      ".config/niri" = {
        recursive = true;
        source = ./niri;
      };

      ".config/swaync" = {
        recursive = true;
        source = ./swaync;
      };
    };

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      XDG_CURRENT_DESKTOP = "sway";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
      QT_QPA_PLATFORM = "wayland";
    };
  };
}
