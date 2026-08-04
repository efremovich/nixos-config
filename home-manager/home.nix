{
  homeStateVersion,
  user,
  ...
}:
{
  imports = [ ../linux-app ];

  stylix.targets = {
    firefox.profileNames = [ "default" ];
    waybar.enable = false;
    neovim.enable = false;
    gtk.enable = true;
    fuzzel.enable = true;
    # k9s.enable = true;
    mako.enable = false;
    swaylock.enable = false;
  };

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = homeStateVersion;
  };
}
