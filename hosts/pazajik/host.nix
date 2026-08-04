# pazajik — десктоп без HASP/1С.
{ user, ... }:
{
  services.getty.autologinUser = user;

  virtualisation.docker.enable = true;
  services.v2raya.enable = true;
}
