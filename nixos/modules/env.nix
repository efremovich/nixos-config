{
  environment.sessionVariables = rec {
    TERMINAL = "alacritty";
    EDITOR = "nvim";
    XDG_BIN_HOME = "$HOME/.local/bin";
    PATH = [ "${XDG_BIN_HOME}" "$HOME/go/bin" ];
    GOPATH = "$HOME/go/bin";
    XDG_CURRENT_DESKTOP = "sway";

    #go env
    GONOPROXY = "*.astralnalog.ru";
    GONOSUMDB = "*.astralnalog.ru";
    GOPRIVATE = "*.astralnalog.ru";
  };
}

