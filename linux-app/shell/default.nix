{
  imports = [
    ./fish.nix
    ./zsh.nix
    ./starship.nix
    ./tmux.nix
  ];

  # Алиасы, общие для всех shell (fish/zsh подхватывают home.shellAliases).
  home.shellAliases = {
    sw = "nh os switch";
    upd = "nh os switch --update";

    pkgs = "nvim ~/.nix/linux-app/packages.nix";

    r = "ranger";
    v = "nvim";
    se = "sudoedit";
    microfetch = "microfetch && echo";

    gs = "git status";
    ga = "git add";
    gc = "git commit";
    gp = "git push";

    ".." = "cd ..";
  };
}
