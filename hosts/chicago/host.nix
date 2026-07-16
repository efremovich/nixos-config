# chicago — рабочая станция (1С / HASP, VPN, docker).
{
  virtualisation.docker.enable = true;
  services = {
    v2raya.enable = true;
    hasp.enable = true;
    ideco.enable = true;
  };

  programs.obs-studio.enable = true;
}
