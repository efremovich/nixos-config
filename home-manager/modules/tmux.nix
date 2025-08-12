{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    mouse = true;
    escapeTime = 0;
    keyMode = "vi";
    terminal = "screen-256color";
    extraConfig = ''
      set -as terminal-features ",alacritty*:RGB"
      bind -n M-r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

      bind '%' split-window -c '#{pane_current_path}' -h
      bind '"' split-window -c '#{pane_current_path}'
      bind c new-window -c '#{pane_current_path}'
      bind-key x kill-pane # skip "kill-pane 1? (y/n)" prompt (cmd+w)

      bind-key -n Home send Escape "OH"
      bind-key -n End send Escape "OF"

      set -g status-position top       # macOS / darwin style
      set -g status-left-length 100    # increase length (from 10)

      bind-key "T" run-shell "sesh connect \"$(
        sesh list --icons | fzf-tmux -p 80%,70% \
          --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
          --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
          --bind 'tab:down,btab:up' \
          --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
          --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
          --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
          --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
          --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
          --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
          --preview-window 'right:55%' \
          --preview 'sesh preview {}'
      )\""

      bind-key "K" display-popup -E -w 40% "sesh connect \"$(
        sesh list -i | gum filter --limit 1 --no-sort --fuzzy --placeholder 'Pick a sesh' --height 50 --prompt='⚡'
      )\""

    '';
    plugins = with pkgs; [{

      plugin = tmuxPlugins.catppuccin;
      extraConfig = ''
        set -g status-left "#{E:@catppuccin_status_session}"
        set -g @catppuccin_flavor "latte"
        set -g @catppuccin_window_status_style "basic"
      '';
    }
    # {
    #   plugin = tmuxPlugins.resurrect;
    #   extraConfig = "set -g @resurrect-strategy-nvim 'session'";
    # }
    # {
    #   plugin = tmuxPlugins.continuum;
    #   extraConfig = ''
    # set -g @continuum-restore 'on'
    # set -g @continuum-save-interval '60' # minutes
    #   '';
    # }
      ];
  };
}
