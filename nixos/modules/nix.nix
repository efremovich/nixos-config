{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "docker-28.5.2"
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  programs.nix-ld.enable = true;
}
