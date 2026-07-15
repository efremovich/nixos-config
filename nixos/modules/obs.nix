# Enable from host: programs.obs-studio.enable = true;
{ lib, pkgs, config, ... }:
{
  config = lib.mkIf config.programs.obs-studio.enable {
    programs.obs-studio = {
      package = pkgs.obs-studio.override {
        cudaSupport = true;
      };

      plugins = with pkgs.obs-studio-plugins; [
        obs-gstreamer
        obs-pipewire-audio-capture
        obs-vaapi
      ];
    };
  };
}
