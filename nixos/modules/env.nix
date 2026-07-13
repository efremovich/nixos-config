{
  environment.sessionVariables = {
    TERMINAL = "ghostty";
    EDITOR = "nvim";
    PATH = [
      "$HOME/go/bin"
      "$HOME/.local/bin"
      "$HOME/.local/share/nvim/mason/bin"
    ];
    GOPATH = "$HOME/go";
    XDG_CURRENT_DESKTOP = "niri";
    #go env
    GONOPROXY = "*.astralnalog.ru";
    GONOSUMDB = "*.astralnalog.ru";
    GOPRIVATE = "*.astralnalog.ru";
  };
}
