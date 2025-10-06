{
  programs.git = {
    enable = true;
    userName = "Efremov Aleksandr";
    userEmail = "efremov_an@astralnalog.ru";
    extraConfig = {
      pull.rebase = true;
      url."ssh://git@git.astralnalog.ru/".insteadOf =
        "https://git.astralnalog.ru/";
      url."ssh://git@git.laretto.ru:9822/".insteadOf =
        "https://git.laretto.ru/";
      url."ssh://git@git.autocard-yug.ru:9822/".insteadOf =
        "https://git.autocard-yug.ru/";
    };
  };
}
