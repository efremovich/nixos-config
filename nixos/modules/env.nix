{ config, lib, ... }:
let
  # Fallback для автодетекта светлого/тёмного фона (omp, neovim, fish и др.),
  # когда OSC 11 недоступен (ssh, detached tmux, TERM=dumb). Приоритет у OSC 11,
  # поэтому на обычных терминалах значение игнорируется.
  # Формат "fg;bg": второе поле — индекс фона, >=8 = светлый.
  colorfgbg = if config.stylix.polarity == "light" then "0;15" else "15;0";
in
{
  environment.sessionVariables = {
    TERMINAL = "alacritty";
    EDITOR = "nvim";
    COLORFGBG = colorfgbg;
    PATH = [
      "$HOME/go/bin"
      "$HOME/.local/bin"
      "$HOME/.local/share/nvim/mason/bin"
    ];
    GOPATH = "$HOME/go";
    XDG_CURRENT_DESKTOP = "niri";
    XDG_DATA_DIRS = lib.mkBefore [ "/usr/local/share" ];
    GONOPROXY = "*.astralnalog.ru";
    GONOSUMDB = "*.astralnalog.ru";
    GOPRIVATE = "*.astralnalog.ru";
  };

  # tmux не наследует env клиента для новых панелей (сервер долгоживущий),
  # поэтому то же значение уходит в home-manager → tmux.conf (`set-environment -g`).
  home-manager.extraSpecialArgs.colorfgbg = colorfgbg;
}
