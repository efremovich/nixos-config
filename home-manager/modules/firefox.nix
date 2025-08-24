{ config, pkgs, ... }: {
  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      userContent = ''
        #TabsToolbar {
            visibility: collapse !important;
        }
      '';
    };
  };
  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
}
