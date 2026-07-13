{
  services.mako = {
    enable = false;
    settings = {
      # Внешний вид
      border-radius = 4;
      background-color = "#eff1f5";
      text-color = "#4c4f69";
      border-color = "#8839ef";
      progress-color = "#ccd0da";
      font = "CaskaydiaCoveNerdFontPropo 13";

      # Позиция и размеры
      anchor = "top-right"; # Фиксированная позиция
      layer = "overlay";
      margin = 10;
      height = 500;
      width = 600;

      # Поведение
      default-timeout = 15000; # 15 секунд для обычных
      ignore-timeout = false; # Не игнорировать таймаут при наведении
      sort = "-time";

      # Иконки
      icons = true;
      max-icon-size = 64;

    };
    extraConfig = "
    [urgency=low]
      border-color=#fe640b
    [category=mpd]
      default-timeout=2000
      group-by=category
      ";
  };
}
