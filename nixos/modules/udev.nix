{ pkgs, ... }: { services.udev.packages = with pkgs; [ platformio.udevRules ]; }
