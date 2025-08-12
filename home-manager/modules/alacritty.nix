{ lib, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      window.opacity = 1.0;

      font = {
        builtin_box_drawing = true;
        normal = { style = lib.mkForce "Bold"; };
      };
      window = {
        padding.x = 15;
        padding.y = 15;
      };
      cursor = {
          style ={
    shape =  "Block"; # или Beam (для Insert)
    blinking=  "On";
    };
        };
    };
  };
}
