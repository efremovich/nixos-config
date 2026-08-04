{ lib, ... }:
{
  programs = {
    alacritty = {
      enable = true;
      settings = {
        window = {
          opacity = 1.0;
          decorations = "NONE";

          dynamic_title = true;
          padding.x = 15;
          padding.y = 15;

        };
        font = {
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
        cursor = {
          style = {
            shape = "Block"; # или Beam (для Insert)
            blinking = "On";
          };
        };
      };
    };
  };

}
