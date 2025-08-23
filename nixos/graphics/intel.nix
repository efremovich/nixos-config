{ pkgs, config, ... }: {
  # Включение драйверов Intel
  hardware.opengl = {
    enable = true;
    driSupport = true;
    extraPackages = with pkgs; [ intel-media-driver libva-utils ];
  };

  # Vulkan
  hardware.vulkan.enable = true;
  hardware.vulkan.extraPackages = with pkgs; [ vulkan-tools ];

  # Для Wayland и niri
  services.xserver.enable = false;

  # Если используется Wayland (например, Sway или GNOME на Wayland)
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1"; # Фикс для курсора в Wayland
  };
}
