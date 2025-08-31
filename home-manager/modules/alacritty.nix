{ lib, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      window.opacity = 1.0;
      window.decorations = "NONE";
      font = {
        builtin_box_drawing = true;
        normal = { style = lib.mkForce "Regular"; };
        bold = { style = lib.mkForce "Bold"; };
        italic = { style = lib.mkForce "Italic"; };
      };
      window = {
        padding.x = 15;
        padding.y = 15;
      };
      cursor = {
        style = {
          shape = "Block"; # или Beam (для Insert)
          blinking = "On";
        };
      };
    };
  };
}
