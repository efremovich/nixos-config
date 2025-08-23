{ pkgs, ... }: {
  services.swayidle = {
    enable = true;
    events = [
      {
        event = "before-sleep";
        command = "loginctl lock-session";
      }
      {
        event = "lock";
        command = "swaylock";
      }
    ];
    timeouts = [
      {
        timeout = 180;
        command = "brightnessctl -s set 30";
        resumeCommand = "brightnessctl -r";
      }
      {
        timeout = 300;
        command = "loginctl lock-session";
      }
      {
        timeout = 600;
        command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
        resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
      }
      {
        timeout = 1200;
        command = "systemctl suspend";
      }
    ];
  };
}
