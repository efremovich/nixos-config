{ lib, ... }:
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
    XDG_CURRENT_DESKTOP = "niri";
    # Ideco and other FHS installs drop .desktop files under /usr/local/share.
    XDG_DATA_DIRS = lib.mkBefore [ "/usr/local/share" ];
    #go env
    GONOPROXY = "*.astralnalog.ru";
    GONOSUMDB = "*.astralnalog.ru";
    GOPRIVATE = "*.astralnalog.ru";
  };
}
