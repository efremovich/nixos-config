# Ref: https://github.com/hallettj/home.nix/blob/main/home-manager/features/niri/swayidle.nix
{ pkgs, lib, ... }:
let niri-bin = "${pkgs.niri}/bin/niri";
in {
  home.packages = with pkgs; [ swaylock ];
  services.swayidle = let
    seconds = 1;
    minutes = 60 * seconds;
    screen-blank-timeout = 10 * minutes;
    lock-after-blank-timeout = 15 * minutes;
    sleep-timeout = 25 * minutes;

    loginctl = "${pkgs.systemd}/bin/loginctl";
    systemctl = "${pkgs.systemd}/bin/systemctl";
    swaylock = "${pkgs.swaylock}/bin/swaylock";

    lock-session = pkgs.writeShellScript "lock-session" ''
      ${swaylock} -f
      ${niri-bin} msg action power-off-monitors
    '';

    before-sleep = pkgs.writeShellScript "before-sleep" ''
      ${loginctl} lock-session
    '';
  in {
    enable = true;
    timeouts = [
      {
        timeout = screen-blank-timeout;
        command = "${niri-bin} msg action power-off-monitors";
      }
      {
        timeout = screen-blank-timeout + lock-after-blank-timeout;
        command = "${loginctl} lock-session";
      }
      {
        timeout = sleep-timeout;
        command = "${systemctl} suspend";
      }
    ];
    events = [
      {
        event = "lock";
        command = lock-session.outPath;
      }
      {
        event = "before-sleep";
        command = before-sleep.outPath;
      }
    ];
    systemdTarget = "niri.service";
  };

  systemd.user.services.swayidle.Unit.After = lib.mkForce "niri.service";
}
