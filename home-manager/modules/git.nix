{
  programs.git = {
    enable = true;
    userName = "Efremov Aleksandr";
    userEmail = "efremov_an@astralnalog.ru";
    extraConfig = {
      pull.rebase = true;
      url."ssh://git@git.astralnalog.ru/".insteadOf =
        "https://git.astralnalog.ru/";
    };
  };
}
