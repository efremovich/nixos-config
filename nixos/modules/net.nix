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
      # "192.168.1.188" = [ "mail.astralnalog.ru" ];
      # "10.10.49.4" = [ "tfs.astralnalog.ru" ];
      # "10.10.49.200" = [ "git.astralnalog.ru" ];
      # "192.168.112.43" = [ "registry.astralnalog.ru" ];
      "10.0.64.10" = [
        "grafana-devops.astralnalog.ru"
        "kibana.astralnalog.ru"
      ];
      # "192.168.112.46" = [ "vault.astralnalog.ru" ];
      "10.10.13.125" = [
        "dex-edo.astralnalog.ru"
        "kube-dash-edo.astralnalog.ru"
        "kube-api-edo.astralnalog.ru"
      ];
      "10.0.29.11" = [ "monitoring.operator.etpgpb.ru" ];
      # "10.10.44.125" = [
      #   "monitoring-preprod-edo-point.astralnalog.ru"
      #   "kube-api-prod-edo-point.astralnalog.ru"
      # ];
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
    # strongSwan configuration file
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

    # include strongswan.d/*.conf
    include strongswan.d/*.conf
  '';
}
