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
    walker.url = "github:abenz1267/walker";
    darwin = {
      url = "github:talhaHavadar/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    system-manager = {
      url = "github:numtide/system-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-system-graphics = {
      url = "github:soupglasses/nix-system-graphics";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
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
      system-manager,
      nix-system-graphics,
      ...
    }@inputs:
    let
      mkHomeConfiguration =

        { system, username, ... }@args:
        home-manager.lib.homeManagerConfiguration (
          {
            modules = [
              ./users.nix
              ./home.nix
            ];
            pkgs = import nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
              };
              overlays = [
                #                inputs.nixgl.overlay
              ];
            };
            extraSpecialArgs = {
            };

          }
          // {
            inherit (args) extraSpecialArgs;
          }
        );
      username = builtins.getEnv "USER";
      system = builtins.currentSystem;
      platform = builtins.getEnv "NIX_PLATFORM";
    in
    {
      default = { };

      nixosConfigurations.surface = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          username = "benis";
          platform = "nixos";
          currentConfigSystem = "nixos";
        };
        modules = [
          ./users.nix
          nixos-hardware.nixosModules.microsoft-surface-common
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
          (import ./machines/surface)
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.benis.imports = [
              ./home/benis
              ./home.nix
            ];
            home-manager.users.talha.imports = [
              ./home/talha
              ./home.nix
            ];
            home-manager.extraSpecialArgs = {
              inherit inputs;
              system = "x86_64-linux";
              platform = "nixos";
              currentConfigSystem = "home";
            };
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
      systemConfigs.default = system-manager.lib.makeSystemConfig {
        modules = [
          nix-system-graphics.systemModules.default
          ({
            config = {
              nixpkgs.hostPlatform = "x86_64-linux";
              system-manager.allowAnyDistro = true;
              system-graphics.enable = true;
            };
          })
        ];
      };

      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations.mac = darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit username;
          platform = "macos";
          currentConfigSystem = "darwin";
        };
        modules = [
          ./machines/mac
          ./users.nix
          mac-app-util.darwinModules.default
          home-manager.darwinModules.home-manager
          {
            # To enable it for all users:
            home-manager.sharedModules = [
              mac-app-util.homeManagerModules.default
            ];

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
            home-manager.extraSpecialArgs = {
              inherit inputs;
              inherit username;
              platform = "macos";
              currentConfigSystem = "home";
            };
            home-manager.users.talha.imports = [
              ./users.nix
              ./home.nix
            ];
          }
        ];
      };

      # homeConfigurations."${platform}.${username}" = mkHomeConfiguration {
      #   inherit system;
      #   inherit username;
      #   extraSpecialArgs = {
      #     inherit username;
      #     inherit inputs;
      #     inherit platform;
      #     packagingEnabled = (builtins.getEnv "INCLUDE_PACKAGING") == "true";
      #     currentConfigSystem = "home";
      #   };
      # };

      homeConfigurations.linux = mkHomeConfiguration {
        inherit system;
        inherit username;
        extraSpecialArgs = {
          inherit username;
          inherit inputs;
          platform = "non-nixos";
          packagingEnabled = (builtins.getEnv "INCLUDE_PACKAGING") == "true";
          currentConfigSystem = "home";
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
          currentConfigSystem = "home";
        };
      };

    };
}
