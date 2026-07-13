{ user, ... }:
{
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 4d --keep 3";
    # Trailing slash avoids nh assertion on paths ending with ".nix"
    flake = "/home/${user}/.nix/";
  };
}
