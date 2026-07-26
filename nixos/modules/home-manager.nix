{
  inputs,
  user,
  homeStateVersion,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.default ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit inputs user homeStateVersion;
    };
  };
}
