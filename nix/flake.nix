{
  description = "NixOS System Configuration Flake from tchavadar";

  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:talhaHavadar/nix-darwin/7f5231c";
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
      url = "github:NixOS/nixos-hardware/feefc78";
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      darwin,
      nixvim,
      mac-app-util,
      nixos-hardware,
      ...
    }@inputs:
    let
      mkHomeConfiguration =
        { system, username, ... }@args:
        home-manager.lib.homeManagerConfiguration (
          {
            modules = [
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
            ];
            home-manager.extraSpecialArgs = {
              inherit inputs;
              username = "benis";
              system = "x86_64-linux";
              platform = "nixos";
            };
            home-manager.backupFileExtension = "backup";
          }
        ];
      };

      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations.macmini = darwin.lib.darwinSystem {

        system = "aarch64-darwin";
        specialArgs = {
          inherit self;
        };
        modules = [
          mac-app-util.darwinModules.default
          ./machines/macmini
          (
            { ... }:
            {
              users.users.talha = {
                name = "talha";
                home = "/Users/talha";
              };
            }
          )
          home-manager.darwinModules.home-manager
          {
            # To enable it for all users:
            home-manager.sharedModules = [
              mac-app-util.homeManagerModules.default
            ];

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.talha.imports = [
              ./home.nix
            ];
            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
            home-manager.extraSpecialArgs = {
              inherit inputs;
              username = "talha";
              system = "aarch64-darwin";
              platform = "macos";
            };
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations.macmini.pkgs;

      homeConfigurations.linux = mkHomeConfiguration {
        inherit system;
        inherit username;
        extraSpecialArgs = {
          inherit username;
          inherit inputs;
          platform = "non-nixos";
        };
      };

    };
}
