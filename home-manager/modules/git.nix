{ tfsGitExtraHeader, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Efremov Aleksandr";
      user.email = "efremov_an@astral.ru";
      pull.rebase = true;
      http = {
        "https://tfs.astralnalog.ru/" = {
          extraHeader = "Authorization: Basic ${tfsGitExtraHeader}";
        };
      };
      url = {
        "ssh://git@git.astralnalog.ru:60001/".insteadOf = "https://git.astralnalog.ru/";
        # "ssh://tfs.astralnalog.ru:22/".insteadOf = "https://tfs.astralnalog.ru/";
        "ssh://git@git.autocard-yug.ru:9822/".insteadOf = "https://git.autocard-yug.ru/";
      };
    };
  };
}
