# https://github.com/Alexays/Waybar
{
  config,
  pkgs,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  python3 = "${pkgs.python3}/bin/python3";
  operatorQueues = "${homeDir}/.config/waybar/operator-queues.py";
in
{
  home = {
    file = {
      ".config/waybar/toggl_status.py".source = ./toggl_status.py;
      ".config/waybar/vpn_status.py".source = ./vpn_status.py;
      ".config/waybar/vpn_toggle.py".source = ./vpn_toggle.py;
      ".config/waybar/ssh_tunnel_status.py".source = ./ssh_tunnel_status.py;
      ".config/waybar/ssh_tunnel_toggle.py".source = ./ssh_tunnel_toggle.py;
      ".config/waybar/operator-queues.py".source = ./operator-queues.py;
    };
  };
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    style = ./style.css;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        mod = "dock";
        margin-left = 15;
        margin-right = 15;
        margin-top = 4;
        margin-bottom = 4;
        reload_style_on_change = true;
        spacing = 0;
        modules-left = [
          # "custom/spacer"
          # "image"
          "niri/workspaces"
          "wlr/taskbar"
          "niri/window"
          "custom/window-icon"
        ];
        modules-center = [
          "custom/clock-icon"
          "clock"
          "custom/operator-queues-icon"
          "custom/operator-queues"
          # "custom/pomodoro-icon"
          # "custom/pomodoro"
        ];

        modules-right = [
          # "custom/toggl-icon"
          # "custom/toggl"
          "custom/mpris-icon"
          "mpris"
          "custom/language-icon"
          "niri/language"
          "memory"
          "cpu"
          "backlight"
          "battery"
          "battery#bat2"
          "network"
          # "custom/vpn"
          "custom/ssh-tunnel"
          "idle_inhibitor"
          "pulseaudio"
          "tray"
        ];

        # Module configuration: Left
        "custom/spacer" = {
          format = "   ";
          on-click = "niri msg action toggle-overview";
        };
        "image" = {
          path = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
          on-click = "niri msg action toggle-overview";
          size = 22;
          tooltip = false;
        };
        "niri/workspaces" = {
          all-outputs = false;
          on-click = "activate";
          current-only = false;
          disable-scroll = false;
          icon-theme = "Papirus-Light";
          format = "<span><b>{icon}</b></span>";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
            "7" = "7";
            "8" = "8";
            "9" = "9";
          };
        };
        "wlr/taskbar" = {
          all-outputs = false;
          format = "{icon}";
          icon-theme = "Papirus-Light";
          icon-size = 16;
          tooltip = true;
          tooltip-format = "{title}";
          active-first = true;
          on-click = "activate";
        };
        "niri/window" = {
          max-length = 50;
          format = "<span foreground='#89b4fa'>󰊠</span> {title}";
          separate-outputs = true;
          on-click = "niri msg action toggle-overview";
          rewrite = {
            "" = "<span foreground='#89b4fa'> Niri</span>";
          };
        };

        "niri/language" = {
          format = "{short}";
        };

        # Module configuration: Center
        clock = {
          format = "<b>{:%a %b[%m] %d ▒ %H:%M}</b>";
          tooltip-format = ''
            <big>{:%Y %B}</big>
            <tt><small>{calendar}</small></tt>'';
          format-alt = "{:%H:%M %d.%m.%Y}";
        };

        # Module configuration: Right
        pulseaudio = {
          format = "{icon}";
          format-bluetooth = "󰂰";
          format-muted = " muted";
          tooltip-format = "{name} {volume}%";
          format-icons = {
            "alsa_output.pci-0000_00_1f.3.analog-stereo" = "";
            "alsa_output.pci-0000_00_1f.3.analog-stereo-muted" = "";
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            phone-muted = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
            ];
          };
          scroll-step = 1;
          on-click = "pavucontrol";
        };
        network = {
          format-wifi = " ";
          format-ethernet = " ";
          tooltip-format = "{essid} ({signalStrength}%)";
          format-linked = "󰛵 ";
          format-disconnected = "󰅛 ";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };
        memory = {
          interval = 1;
          rotate = 270;
          format = "{icon}";
          format-icons = [
            "<span color='#7287fd'>󰝦</span>"
            "<span color='#7287fd'>󰪞</span>"
            "<span color='#40a02b'>󰪟</span>"
            "<span color='#40a02b'>󰪠</span>"
            "<span color='#df8e1d'>󰪡</span>"
            "<span color='#fe640b'>󰪢</span>"
            "<span color='#e64553'>󰪣</span>"
            "<span color='#d20f39'>󰪤</span>"
            "<span color='#d20f39'>󰪥</span>"
          ];
          max-length = 10;
        };
        cpu = {
          interval = 1;
          format = "{icon}";
          rotate = 270;
          format-icons = [
            "<span color='#7287fd'>󰝦</span>"
            "<span color='#7287fd'>󰪞</span>"
            "<span color='#40a02b'>󰪟</span>"
            "<span color='#40a02b'>󰪠</span>"
            "<span color='#df8e1d'>󰪡</span>"
            "<span color='#fe640b'>󰪢</span>"
            "<span color='#e64553'>󰪣</span>"
            "<span color='#d20f39'>󰪤</span>"
            "<span color='#d20f39'>󰪥</span>"
          ];
        };
        backlight = {
          format = "{icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
          ];
        };
        battery = {
          states = {
            # good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{icon}";
          format-charging = "";
          format-plugged = "";
          format-alt = "{capacity}% {icon}";
          # format-icons = ["" "" "" "" "" "" "" ""];
          format-icons = [
            "󰂎"
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          tooltip-format = "{capacity}% {time}";
          tooltip = true;
        };
        "battery#bat2" = {
          bat = "BAT2";
        };
        tray = {
          icon-size = 18;
          spacing = 10;
        };
        "custom/vpn" = {
          format = "{}";
          exec = "$HOME/.config/waybar/vpn_status.py";
          interval = 10;
          on-click = "$HOME/.config/waybar/vpn_toggle.py";
        };
        "custom/ssh-tunnel" = {
          format = "{}";
          exec = "$HOME/.config/waybar/ssh_tunnel_status.py";
          interval = 10;
          on-click = "$HOME/.config/waybar/ssh_tunnel_toggle.py";
          # tooltip = true;
          # tooltip-format = "SSH Tunnel: {icon}";
        };
        "custom/toggl" = {
          format = "{}";
          exec = "$HOME/.config/waybar/toggl_status.py";
          interval = 180;
          on-click = "toggl stop";
        };

        "custom/operator-queues" = {
          exec = "${python3} ${operatorQueues}";
          interval = 5;
          format = "{text}";
          return-type = "json";
          escape = false;
          tooltip = true;
        };

        "idle_inhibitor" = {
          format = "<i>{icon}</i>";
          start-activated = false;
          format-icons = {
            activated = " ";
            deactivated = " ";
          };
          tooltip-format-activated = "Swayidle inactive";
          tooltip-format-deactivated = "Swayidle active";
        };
        mpris = {
          interval = 2;
          format = "{player_icon}{dynamic}{status_icon}";
          format-paused = "{player_icon}{dynamic}{status_icon}";
          tooltip = true;
          tooltip-format = "{dynamic}";
          on-click = "playerctl play-pause";
          on-click-middle = "playerctl previous";
          on-click-right = "playerctl next";
          scroll-step = 5.0;
          smooth-scrolling-threshold = 1;
          dynamic-len = 60;
          player-icons = {
            chromium = " ";
            brave-browser = " ";
            default = " ";
            firefox = " ";
            kdeconnect = " ";
            mopidy = " ";
            mpv = "󰐹 ";
            spotify = " ";
            vlc = "󰕼 ";
          };
          status-icons = {
            playing = "";
            paused = "";
            stopped = "";
          };
        };
        "custom/pomodoro" = {
          format = "{}";
          return-type = "json";
          exec = "waybar-module-pomodoro";
          on-click = "waybar-module-pomodoro toggle";
          on-click-right = "waybar-module-pomodoro reset";
        };
        # Custom icons
        "custom/toggl-icon" = {
          format = "󱎫";
        };
        "custom/audio-icon" = {
          format = "";
        };
        "custom/network-icon" = {
          format = "󰖩";
        };
        "custom/backlight-icon" = {
          format = "󰌵";
        };
        "custom/battery-icon" = {
          format = "󰁹";
        };
        "custom/clock-icon" = {
          format = "";
        };
        "custom/pomodoro-icon" = {
          format = "";
        };
        "custom/operator-queues-icon" = {
          format = "󱓻";
        };
        "custom/mpris-icon" = {
          format = " ";
        };
        "custom/idle-icon" = {
          format = " ";
        };
        "custom/vpn-icon" = {
          format = " ";
        };
        "custom/ssh_tunnel-icon" = {
          format = " ";
        };
        "custom/language-icon" = {
          format = "󰌍 ";
        };
        "custom/window-icon" = {
          format = " ";
          on-click = "walker --modules windows";
          tooltip = "Window list";
        };
      };
    };
  };
}
