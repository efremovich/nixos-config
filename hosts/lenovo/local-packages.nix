{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    gcc
    rustup
    # kdenlive
    # jetbrains.pycharm-professional
    # jre8
    # qemu
    # quickemu
  ];

}
