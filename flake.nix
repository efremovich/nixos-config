# flake.nix
{
  description = "My system configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    # WebKit 2.38 + libsoup 2 (для 1С: uiproxywx.so и WebKit в одном процессе без смешивания libsoup 2 и 3).
    nixpkgs_22_11.url = "github:nixos/nixpkgs/nixos-22.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yandex-browser = {
      url = "github:miuirussia/yandex-browser.nix";
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
      tfsPat = nixpkgs.lib.removeSuffix "\n" (
        builtins.readFile (
          builtins.path {
            path = ./secrets/tfs_pat.txt;
            name = "tfs-pat.txt";
          }
        )
      );
      tfsGitExtraHeader =
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        nixpkgs.lib.removeSuffix "\n" (
          builtins.readFile (
            pkgs.runCommand "tfs-git-basic-auth" { } ''
              ${pkgs.coreutils}/bin/printf '%s' ${nixpkgs.lib.escapeShellArg "efremov_an:${tfsPat}"} \
                | ${pkgs.coreutils}/bin/base64 -w0 > $out
            ''
          )
        );
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
        extraSpecialArgs = { inherit inputs homeStateVersion user tfsGitExtraHeader; };
        modules = [ ./home-manager/home.nix ];
      };
    };
}
