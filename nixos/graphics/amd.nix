{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      egl-wayland
    ];
  };
  services = {
    xserver = {

      videoDrivers = [ "amdgpu" ];
      enable = true;
    };
  };
}
