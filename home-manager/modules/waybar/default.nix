{
  programs.waybar = {
    enable = true;
    style = ./style.css;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "hyprland/language"
          "custom/weather"
          "pulseaudio"
          "battery"
          "cpu"
          "memory"
          "network"
          "clock"
          "tray"
        ];
        "hyprland/workspaces" = {
          disable-scroll = true;
          show-special = true;
          special-visible-only = true;
          all-outputs = false;
          format = "{icon}";
          format-icons = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            "5" = "";
            "6" = "";
            "7" = "";
            "8" = "";
            "9" = "";
            "magic" = "";
          };

          persistent-workspaces = { "*" = 9; };
        };

        "hyprland/language" = {
          format-en = "🇺🇸";
          format-ru = "🇷🇺";
          min-length = 5;
          interval = 1;
          tooltip = false;
        };

        "custom/weather" = {
          format = " {} ";
          exec = "curl -s 'wttr.in/Krasnodar?format=%c%t'";
          interval = 300;
          class = "weather";
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-bluetooth = "{icon} {volume}% ";
          format-muted = "";
          format-icons = {
            "headphones" = "";
            "handsfree" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = [ "" "" ];
          };
          on-click = "pavucontrol";
        };

        "battery" = {
          states = {
            warning = 30;
            critical = 1;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-alt = "{time} {icon}";
          format-icons = [ "" "" "" "" "" ];
        };

        "clock" = {
          format = "{:%d.%m.%Y - %H:%M}";
          format-alt = "{:%A, %B %d at %R}";
        };

        "tray" = {
          icon-size = 14;
          spacing = 1;
        };

        "network"= {
          "format-wifi"= "{icon} {essid} ⇣{bandwidthDownBytes:>} ";
          "format-icons"= [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          "format-ethernet"= "󰀂 ⇣{bandwidthDownBytes:>}" ;
          "format-alt"= "󱛇";
          "format-disconnected"= "󰖪";
          "tooltip-format-wifi"= "{icon} {essid}\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
          "tooltip-format-ethernet"= "󰀂  {ifname}\n⇣{bandwidthDownBytes}  ⇡{bandwidthUpBytes}";
          "tooltip-format-disconnected"= "Disconnected";
          "on-click"= "alacritty -T waybar_nmtui -e nmtui";
          "interval"= 2;
        };
        "cpu"= {
          format = " {usage: >3}%";
          "on-click"= "alacritty -T waybar_btop -e btop";
        };
        "memory"= {
          "format"= " {: >3}%";
          "on-click"= "alacritty -T waybar_btop -e btop";
        };
      };
    };
  };
}
