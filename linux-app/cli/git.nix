{ pkgs, ... }:
let
  tfsCredentialHelper = pkgs.writeShellScript "tfs-git-credential" ''
    if [ "$1" = get ]; then
      echo "username=efremov_an"
      echo "password=$(cat /run/secrets/tfs_pat)"
    fi
  '';
in
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Efremov Aleksandr";
      user.email = "efremov_an@astral.ru";
      pull.rebase = true;
      credential."https://tfs.astralnalog.ru" = {
        helper = toString tfsCredentialHelper;
      };
      url = {
        "ssh://git@git.astralnalog.ru:60001/".insteadOf = "https://git.astralnalog.ru/";
        "ssh://git@git.autocard-yug.ru:9822/".insteadOf = "https://git.autocard-yug.ru/";
      };
    };
  };
}
