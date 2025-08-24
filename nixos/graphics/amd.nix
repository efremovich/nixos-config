{ pkgs, config, ... }: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ egl-wayland nvidia-vaapi-driver amdvlk ];
  };

  services.xserver.videoDrivers = [ "amdgpu" ];
  services.xserver.enable = true;

  # Если используется Wayland (например, Sway или GNOME на Wayland)
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1"; # Фикс для курсора в Wayland
  };
}
