# Desktop role shared by all current hosts.
{
  programs.niri.enable = true;
  virtualisation.docker.enable = true;
  services.resolved.enable = true;
  services.v2raya.enable = true;
  services.hasp.enable = true;
}
