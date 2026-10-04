# maximus — десктоп без HASP/1С.
{ user, ... }:
{
  services.getty.autologinUser = user;

  virtualisation.docker.enable = true;
  services = {
    v2raya.enable = true;
    wireguard-wg0.enable = true;
  };
}
