# eltubu — рабочая станция (1С / HASP, VPN, docker).
{ user, ... }:
{

  virtualisation.docker.enable = true;
  services = {
    getty.autologinUser = user;
    wireguard-wg0.enable = true;
    v2raya.enable = true;
    hasp.enable = true;
    ideco.enable = true;
    kesl = {
      enable = true;
      adminUser = "efremov";
    };
  };
}
