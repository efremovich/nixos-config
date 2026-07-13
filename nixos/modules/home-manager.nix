{ inputs, user, homeStateVersion, ... }:
{
  imports = [ inputs.home-manager.nixosModules.default ];
  home-manager.backupFileExtension = "backup";
  home-manager.extraSpecialArgs = {
    inherit inputs user homeStateVersion;
  };
}
