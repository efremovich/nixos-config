{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.wireguard-tools ];

  networking = {
    firewall.checkReversePath = "loose";

    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
        networkmanager-l2tp
        networkmanager-fortisslvpn
        networkmanager-openconnect
      ];
    };

    hosts = {
      # "192.168.1.1" = [ "homelab.local" ];
    };
  };

  programs = {
    nm-applet = {
      enable = true;
    };
    openvpn3 = {
      enable = true;
    };
  };

  services = {
    wg-netmanager = {
      enable = true;
    };
    xl2tpd = {
      enable = false;
    };
    strongswan = {
      enable = true;
    };
  };
  # Создание конфигурационного файла strongswan
  environment.etc."strongswan.conf".text = ''
    charon {
        # number of worker threads in charon
        threads = 16

        # send strongSwan vendor ID?
        send_vendor_id = yes

        # load the 'random' RNG plugin
        rng_plugin = random

        # plugins to load
        plugins {
          include strongswan.d/charon/*.conf
        }
    }

    include strongswan.d/*.conf
  '';
}
