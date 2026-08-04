# chicago — рабочая станция (1С / HASP, VPN, docker).
{ user, ... }:
{
  services.getty.autologinUser = user;

  virtualisation.docker.enable = true;
  services = {
    v2raya.enable = true;
    hasp.enable = true;
    ideco.enable = true;
  };
}
