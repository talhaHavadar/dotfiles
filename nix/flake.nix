{
  description = "NixOS System Configuration Flake from tchavadar";

  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      darwin,
      nixvim,
      nixos-hardware,
      ...
    }@inputs:
    let
      mkHomeConfiguration =
        { system, username, ... }@args:
        home-manager.lib.homeManagerConfiguration (
          rec {
            modules = [
              {
                home = {
                  inherit username;
                  homeDirectory = "/home/${username}";
                  stateVersion = "24.05";
                };
              }
              (import ./neovim)
              ./home.nix
            ];
            pkgs = import nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
              };
              overlays = [
                inputs.nixgl.overlay
              ];
            };
            extraSpecialArgs =
              {
              };
          }
          // {
            inherit (args) extraSpecialArgs;
          }
        );
      username = builtins.getEnv "USER";
      system = builtins.currentSystem;
    in
    {

      nixosConfigurations.surface = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
        };
        modules = [
          nixos-hardware.nixosModules.microsoft-surface-common
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
          (import ./machines/surface)
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.benis.imports = [
              ./home.nix
              ./home/benis
            ];
            home-manager.extraSpecialArgs = {
              inherit inputs;
              username = "benis";
              device = {
                system = "x86_64-linux";
              };
            };
            home-manager.backupFileExtension = "backup";
          }
        ];
      };

      darwinConfigurations.mini = darwin.lib.darwinSystem {
        specialArgs = {
          inherit inputs;
          device = {
            inherit system;
            inherit username;
          };
        };
        inherit system;
        modules = [
          ./system.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPkgs = true;
            home-manager.users.${username}.imports = [
              ./home.nix
              ./home/${username}.nix
            ];
            home-manager.backupFileExtension = "backup";
          }
          (import ./neovim)
        ];
      };

      homeConfigurations.${username} = mkHomeConfiguration {
        inherit system;
        inherit username;
        extraSpecialArgs = {
          device = {
            inherit system;
          };
          inherit inputs;
        };
      };

    };
}
