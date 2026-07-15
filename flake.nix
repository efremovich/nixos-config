# flake.nix
{
  description = "My system configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    # WebKit 2.38 + libsoup 2 (для 1С: uiproxywx.so и WebKit в одном процессе без смешивания libsoup 2 и 3).
    nixpkgs_22_11.url = "github:nixos/nixpkgs/nixos-22.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixpkgs_22_11,
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
              homeStateVersion
              ;
          };
          modules = [ ./hosts/${hostname}/configuration.nix ];
        };

      inherit (nixpkgs) lib;
      supportedSystems = [ "x86_64-linux" ];

      pkgsFor = lib.genAttrs supportedSystems (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }
      );

      forEachSystem = f: lib.genAttrs supportedSystems (system: f pkgsFor.${system});

    in
    {
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
    };
}
