{
  homeStateVersion,
  user,
  ...
}:
{
  imports = [ ../linux-app ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = homeStateVersion;
  };
}
