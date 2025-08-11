{ pkgs, user, ... }: {
  programs.fish.enable = true;
  programs.zsh.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;
    users.${user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
    };
  };

  services.getty.autologinUser = user;
}
