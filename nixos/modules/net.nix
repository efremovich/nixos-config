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
  # strongSwan/charon expects the standard ipsec.d layout and the NM-l2tp
  # plugin writes secrets there. Sans these, charon logs "reading directory
  # failed: No such file or directory" for each path at boot.
  systemd.tmpfiles.rules = [
    "d /etc/ipsec.d 0700 root root -"
    "d /etc/ipsec.d/cacerts 0700 root root -"
    "d /etc/ipsec.d/aacerts 0700 root root -"
    "d /etc/ipsec.d/ocspcerts 0700 root root -"
    "d /etc/ipsec.d/acerts 0700 root root -"
    "d /etc/ipsec.d/crls 0700 root root -"
    "d /etc/ipsec.d/private 0700 root root -"
    "f /etc/ipsec.d/ipsec.nm-l2tp.secrets 0600 root root -"
    "f /etc/ipsec.d/triplets.dat 0600 root root -"
  ];

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
