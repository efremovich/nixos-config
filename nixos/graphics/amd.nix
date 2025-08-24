{ pkgs, config, ... }: {
  hardware.graphics = {
    enable = true;

    extraPackages = with pkgs; [ egl-wayland nvidia-vaapi-driver ];
  };

  services.xserver.videoDrivers = [ "amdgpu" ];
  services.xserver.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport32Bit = true; # Для 32-битных приложений (например, Wine)
    extraPackages = with pkgs;
      [
        amdvlk # Vulkan-драйвер от AMD
      ];
  };

  # Если используется Wayland (например, Sway или GNOME на Wayland)
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1"; # Фикс для курсора в Wayland
  };
}
