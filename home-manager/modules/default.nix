{
  imports = [
    ./alacritty.nix
    ./bat.nix
    # ./chromium.nix
    ./eza.nix
    ./firefox.nix
    ./fish.nix
    ./git.nix
    # ./hyprland
    ./lazygit.nix
    ./neovim.nix
    # ./obsidian.nix
    # для niri
    ./apps/walker
    ./apps/ghostty
    ./desktops/fuzzel.nix
    ./desktops/niri
    ./desktops/niri/swayidle.nix
    # ./desktops/niri/swaylock.nix
    ./desktops/niri/swaync
    ./desktops/niri/xwayland-satellite.nix
    # ./desktops/qt5.nix
    # ./desktops/services/mako
    ./desktops/waybar
    ./desktops/xdg.nix

    ./k9s.nix
    ./ranger.nix
    ./starship.nix
    ./stylix.nix
    ./tmux.nix
    ./zathura.nix
    ./zoxide.nix
    ./zsh.nix
  ];
}
