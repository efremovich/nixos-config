{ user, ... }:
{
  home-manager.users.${user} = {
    imports = [ ../../home-manager/home.nix ];
  };
}
