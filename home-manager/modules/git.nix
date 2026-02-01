{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Efremov Aleksandr";
      user.email = "efremov_an@astralnalog.ru";
      pull.rebase = true;
      url = {
        "ssh://git@git.astralnalog.ru/".insteadOf =
          "https://git.astralnalog.ru/";
        "ssh://git@git.laretto.ru:9822/".insteadOf =
          "https://git.laretto.ru/";
        "ssh://git@git.autocard-yug.ru:9822/".insteadOf =
          "https://git.autocard-yug.ru/";
      };
    };
  };
}
