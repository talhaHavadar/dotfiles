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
      url = "github:talhaHavadar/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      darwin,
      nixvim,
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
            pkgs = nixpkgs.legacyPackages.${system};
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

      darwinConfigurations = {
        talha = darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs;
            device = {
              inherit system;
              inherit username;
            };
          };
          system = "aarch64-darwin";
          modules = [
            ./system.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPkgs = true;
              home-manager.users.${username} = import ./home.nix;
              home-manager.backupFileExtension = "backup";
            }
            (import ./neovim)
          ];
        };
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
