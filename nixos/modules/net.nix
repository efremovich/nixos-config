{ pkgs, ... }: {
  networking.firewall.checkReversePath = "loose";

  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [ 
      networkmanager-openvpn
      networkmanager-l2tp
      networkmanager-fortisslvpn
      networkmanager-openconnect
    ];
  };

  networking.hosts = {
    "192.168.1.188" = [ "mail.astralnalog.ru" ];
    "192.168.1.143" = [ "tfs.astralnalog.ru" ];
    "192.168.1.137" = [ "git.astralnalog.ru" ];
    "192.168.112.43" = [ "registry.astralnalog.ru" ];
    "10.0.64.10" = [ "grafana-devops.astralnalog.ru" "kibana.astralnalog.ru" ];
    "192.168.112.46" = [ "vault.astralnalog.ru" ];
    "10.10.13.125" =
      [ "dex-edo.astralnalog.ru" "kube-dash-edo.astralnalog.ru" ];
    "10.0.29.11" = [ "monitoring.operator.etpgpb.ru" ];
  };

  programs = {
    nm-applet = { enable = true; };
    openvpn3 = { enable = true; };
  };

  services = {
    wg-netmanager = { enable = true; };
    xl2tpd = { enable = true; };
  };
}
