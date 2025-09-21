{ pkgs, user, ... }: {
  programs.fish.enable = true;
  programs.zsh.enable = true;

  users = {
    defaultUserShell = pkgs.fish;
    users.${user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "docker" ];
    };
  };

  services.getty.autologinUser = user;
}
