# flake.nix
{
  description = "My system configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.niri-stable.follows = "niri-stable";
    };
    niri-stable.url = "github:YaLTeR/niri/v25.08";
  };

  outputs = { self, nixpkgs, home-manager, niri, ... }@inputs:
    let
      inherit (self) outputs;
      system = "x86_64-linux";
      homeStateVersion = "25.05";
      user = "efremov";
      hosts = [
        {
          hostname = "maximus";
          stateVersion = "25.05";
        }
        {
          hostname = "chicago";
          stateVersion = "25.05";
        }
        {
          hostname = "lenovo";
          stateVersion = "25.05";
        }
        {
          hostname = "pazajik";
          stateVersion = "25.05";
        }
      ];
      makeSystem = { hostname, stateVersion }:
        nixpkgs.lib.nixosSystem {
          system = system;
          specialArgs = { inherit inputs stateVersion hostname user; };
          modules = [ ./hosts/${hostname}/configuration.nix ];
        };
    in {
      overlays = import ./overlays { inherit inputs outputs; };

      nixosConfigurations = nixpkgs.lib.foldl' (configs: host:
        configs // {
          "${host.hostname}" =
            makeSystem { inherit (host) hostname stateVersion; };
        }) { } hosts;

      homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { inherit inputs homeStateVersion user; };
        modules = [ ./home-manager/home.nix ];
      };

      # # Экспортим niri для использования в модулях
      # overlays.default = final: prev: {
      #   inherit (niri.packages.${system}) niri niri-stable niri-unstable;
      # };
    };
}
