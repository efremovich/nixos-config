{ config, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = let flakeDir = "~/.nix";
    in {
      sw = "nh os switch";
      upd = "nh os switch --update";
      hms = "nh home switch";

      pkgs = "nvim ${flakeDir}/nixos/packages.nix";

      r = "ranger";
      v = "nvim";
      se = "sudoedit";
      microfetch = "microfetch && echo";

      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";

      upnix = "sudo nixos-rebuild switch --flake ${flakeDir}";
      uphome = "home-manager switch --flake ${flakeDir}";

      ".." = "cd ..";
    };

    history.size = 10000;
    history.path = "${config.xdg.dataHome}/zsh/history";

    initExtra = "";

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
