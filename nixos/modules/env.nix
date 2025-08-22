{
  environment.sessionVariables = rec {
    TERMINAL = "alacritty";
    EDITOR = "nvim";
    XDG_BIN_HOME = "$HOME/.local/bin";
    PATH = [ "${XDG_BIN_HOME}" "$HOME/go/bin" ];
    XDG_CURRENT_DESKTOP = "sway";
  };
}

