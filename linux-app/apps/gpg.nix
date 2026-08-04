{
  # gpg-agent — единственный SSH-агент (SSH_AUTH_SOCK выставляет HM-модуль).
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    defaultCacheTtl = 3600;
  };
}
