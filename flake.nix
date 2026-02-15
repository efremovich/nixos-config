# flake.nix
{
  description = "My system configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      homeStateVersion = "25.11";
      user = "efremov";
      hosts = [
        {
          hostname = "maximus";
          stateVersion = "25.11";
        }
        {
          hostname = "chicago";
          stateVersion = "25.11";
        }
        {
          hostname = "lenovo";
          stateVersion = "25.11";
        }
        {
          hostname = "pazajik";
          stateVersion = "25.11";
        }
      ];
      makeSystem =
        { hostname, stateVersion }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              stateVersion
              hostname
              user
              ;
          };
          modules = [ ./hosts/${hostname}/configuration.nix ];
        };

      # Исправляем определение lib и pkgsFor
      inherit (nixpkgs) lib;
      supportedSystems = [ "x86_64-linux" ];

      # Функция для создания pkgs для каждой системы
      pkgsFor = lib.genAttrs supportedSystems (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );

      # Функция для создания devShells для каждой системы
      forEachSystem = f: lib.genAttrs supportedSystems (system: f pkgsFor.${system});

    in
    {
      # overlays = import ./overlays { inherit inputs outputs; };

      # Исправляем devShells
      devShells = forEachSystem (pkgs: {
        default = import ./shell.nix { inherit pkgs; };
      });

      nixosConfigurations = builtins.listToAttrs (
        map (host: {
          name = host.hostname;
          value = makeSystem {
            inherit (host) hostname;
            inherit (host) stateVersion;
          };
        }) hosts
      );

      homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { inherit inputs homeStateVersion user; };
        modules = [ ./home-manager/home.nix ];
      };
    };
}
