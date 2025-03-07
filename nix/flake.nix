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
      url = "github:NixOS/nixos-hardware/feefc78";
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

      homeConfigurations.linux = mkHomeConfiguration {
        inherit system;
        inherit username;
        extraSpecialArgs = {
          inherit username;
          inherit inputs;
          platform = "non-nixos";
        };
      };
      homeConfigurations.ubuntu-headless = mkHomeConfiguration {
        inherit system;
        username = "ubuntu";
        extraSpecialArgs = {
          username = "ubuntu";
          inherit inputs;
          platform = "ubuntu-headless";
          packagingEnabled = (builtins.getEnv "INCLUDE_PACKAGING") == "true";
        };
      };

    };
}
