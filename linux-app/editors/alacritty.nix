{ lib, ... }:
{

  programs.alacritty.enable = true;

  programs.alacritty.settings.window.opacity = 1.0;
  programs.alacritty.settings.window.decorations = "NONE";
  programs.alacritty.settings.font = {
    builtin_box_drawing = true;
    normal = {
      style = lib.mkForce "Regular";
    };
    bold = {
      style = lib.mkForce "Bold";
    };
    italic = {
      style = lib.mkForce "Italic";
    };
  };
  programs.alacritty.settings.window = {
    padding.x = 15;
    padding.y = 15;
  };
  programs.alacritty.settings.cursor = {
    style = {
      shape = "Block"; # или Beam (для Insert)
      blinking = "On";
    };
  };

}
