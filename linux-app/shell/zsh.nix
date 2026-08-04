{ config, ... }:
{
  programs.zsh = {
    enable = true;
    # HM 26.05: lock legacy default (dotfiles in $HOME) until XDG migration.
    dotDir = config.home.homeDirectory;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Общие алиасы — в home.shellAliases (shell/default.nix)
    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";

    initContent = ''
      function sesh-sessions() {
        {
          exec </dev/tty
          exec <&1
          local session
          session=$(sesh list | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
          zle reset-prompt > /dev/null 2>&1 || true
          [[ -z "$session" ]] && return
          sesh connect $session
        }
      }

      zle     -N             sesh-sessions
      bindkey -M emacs '\ek' sesh-sessions
      bindkey -M vicmd '\ek' sesh-sessions
      bindkey -M viins '\ek' sesh-sessions
    '';
  };
}
