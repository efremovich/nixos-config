{ config, lib, ... }:
let
  cfg = config.services.wireguard-wg0;
in
{
  options.services.wireguard-wg0.enable = lib.mkEnableOption "the wg0 WireGuard tunnel";

  config = lib.mkIf cfg.enable {
    sops.secrets.wg0 = {
      sopsFile = ../../secrets/wg0.conf;
      format = "binary";
      owner = "root";
      mode = "0400";
    };

    networking.wg-quick.interfaces.wg0 = {
      autostart = false;
      configFile = config.sops.secrets.wg0.path;
    };

    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") == "wg-quick-wg0.service" &&
            ["start", "stop"].includes(action.lookup("verb")) &&
            subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
