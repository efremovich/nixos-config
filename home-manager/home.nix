{
  homeStateVersion,
  user,
  ...
}:
{
  imports = [
    ./modules
    ./home-packages.nix
  ];

  # kesl.enable = true;

  home = {
    username = user;
    homeDirectory = "/home/${user}";
    stateVersion = homeStateVersion;
  };
}
