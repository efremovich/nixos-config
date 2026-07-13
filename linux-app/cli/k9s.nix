{
  programs.k9s = {
    enable = true;
    settings = {
      k9s = {
        ui = {
          enableMouse = false;
          headless = true;
          logoless = true;
        };
      };
    };
  };
}
