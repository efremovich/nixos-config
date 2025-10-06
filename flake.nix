# flake.nix
{
  description = "My system configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

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
          inherit system;
          specialArgs = { inherit inputs stateVersion hostname user; };
          modules = [ ./hosts/${hostname}/configuration.nix ];
        };

      # Исправляем определение lib и pkgsFor
      lib = nixpkgs.lib;
      supportedSystems = [ "x86_64-linux" ];

      # Функция для создания pkgs для каждой системы
      pkgsFor = lib.genAttrs supportedSystems (system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        });

      # Функция для создания devShells для каждой системы
      forEachSystem = f:
        lib.genAttrs supportedSystems (system: f pkgsFor.${system});

    in {
      # overlays = import ./overlays { inherit inputs outputs; };

      # Исправляем devShells
      devShells = forEachSystem
        (pkgs: { default = import ./shell.nix { inherit pkgs; }; });

      nixosConfigurations = builtins.listToAttrs (map (host: {
        name = host.hostname;
        value = makeSystem {
          hostname = host.hostname;
          stateVersion = host.stateVersion;
        };
      }) hosts);

      homeConfigurations.${user} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        extraSpecialArgs = { inherit inputs homeStateVersion user; };
        modules = [ ./home-manager/home.nix ];
      };
    };
}
