{ pkgs, user, ... }:
{
  programs.fish.enable = true;
  programs.zsh.enable = true;

  users = {
    defaultUserShell = pkgs.fish;
    users.${user} = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
        "storage"
        "dialout"
        "plugdev"
        "kvm"
      ];
    };
  };

  # Включение udisks2 для монтирования съемных носителей
  services.udisks2.enable = true;
}
