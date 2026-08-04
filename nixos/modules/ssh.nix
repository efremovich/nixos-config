{ user, ... }:
{
  services.openssh = {
    enable = true;
    settings = {
      # При переводе всех хостов на ключи выставить false.
      PasswordAuthentication = true;
      PermitRootLogin = "no";
      AllowUsers = [ user ];
    };
  };
}
