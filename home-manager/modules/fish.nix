{ pkgs, ... }: {
  programs.fish = {
    enable = true;

    shellInit = ''
      zoxide init fish | source

      # Executed for all fish instances
      set -x PATH $HOME/.local/bin $PATH
      set -x PATH $HOME/go/bin $PATH
      # Запуск sesh-session только при запуске в новом терминале (не в сабшелле)
      if status is-interactive
          # Проверяем, что мы не в сессии уже запущенного sesh
        if not set -q TMUX
          if not set -q SESHSOCK
              sesh-sessions
          end
        end
      end
    '';

    interactiveShellInit = ''
      # Only executed for interactive shells
      set fish_greeting ""  # Disable greeting
      # fish_config theme save "Catppuccin Latte"
    '';
    plugins = [{
      name = "fish";
      src = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "fish";
        rev = "6a85af2ff722ad0f9fbc8424ea0a5c454661dfed";
        sha256 = "sha256-Oc0emnIUI4LV7QJLs4B2/FQtCFewRFVp7EDv8GawFsA=";
      };
    }];
    shellAliases = {
      sw = "nh os switch";
      upd = "nh os switch --update";
      hms = "nh home switch";

      pkgs = "nvim ~/.nix/nixos/packages.nix";

      r = "ranger";
      v = "nvim";
      se = "sudoedit";
      microfetch = "microfetch && echo";

      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";

      upnix = "sudo nixos-rebuild switch --flake ~/.nix";
      uphome = "home-manager switch --flake ~/.nix";

      ".." = "cd ..";
    };

    functions = {
      # Функция для выбора и подключения к sesh-сессии через fzf
      sesh-sessions = {
        body = ''
          set -l session (sesh list | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
          if [ -n "$session" ]
              sesh connect $session
          end
        '';
      };
    };
  };
}
