{ lib, pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Efremov Aleksandr";
      user.email = "efremov_an@astral.ru";
      pull.rebase = true;
      include = {
        path = "~/.config/git/tfs-auth";
      };
      url = {
        "ssh://git@git.astralnalog.ru:60001/".insteadOf = "https://git.astralnalog.ru/";
        "ssh://git@git.autocard-yug.ru:9822/".insteadOf = "https://git.autocard-yug.ru/";
      };
    };
  };
}
