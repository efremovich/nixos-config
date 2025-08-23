{ pkgs, ... }: {
  services.swaybg = {
    enable = true;
    image = "${pkgs.fetchurl {
      url = "https://w.wallhaven.cc/full/7j/wallhaven-7j3lve.png";
      sha256 = "kko5Uiq7H0DqiT2aDYbaQCNRzs+5AleaATzsXi3xgQA=";
    }}";
    mode = "fill";
  };
}
