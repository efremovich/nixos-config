{
  environment.sessionVariables = {
    TERMINAL = "alacritty";
    EDITOR = "nvim";
    PATH = [
      "$HOME/go/bin"
      "$HOME/.local/bin"
      "$HOME/.local/share/nvim/mason/bin"
    ];
    GOPATH = "$HOME/go";
    XDG_CURRENT_DESKTOP = "sway";
    #go env
    GONOPROXY = "*.astralnalog.ru";
    GONOSUMDB = "*.astralnalog.ru";
    GOPRIVATE = "*.astralnalog.ru";
  };
}
