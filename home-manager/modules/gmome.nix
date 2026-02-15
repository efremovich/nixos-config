{ pkgs, ... }:
{
  environment.gnome = {
    excludePackages = (
      with pkgs;
      [
        evince # document viewer
      ]
    );
  };
}
