{ pkgs, ... }: {
  home.packages = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
    thunar-media-tags-plugin
  ];

  # Настройка thunar-volman для автоматического монтирования флешек
  xdg.configFile."Thunar/volmanrc".text = ''
    [Configuration]
    # Автоматическое монтирование съемных носителей при подключении
    automount-drives=true
    automount-media=true
    autorun-never=true
    # Автоматическое открытие Thunar при монтировании
    auto-open=true
  '';
}
