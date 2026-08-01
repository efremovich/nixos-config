{
  programs.firefox = {
    enable = true;
    # HM 26.05: keep profile in ~/.mozilla/firefox (not XDG).
    configPath = ".mozilla/firefox";
    profiles.default = {
      settings = {
        "browser.toolbars.visible" = false; # Hides the entire toolbar
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };
      userChrome = ''
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
