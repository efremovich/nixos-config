{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "docker-28.5.2"
    "libsoup-2.74.3"
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  programs.nix-ld.enable = true;
}
