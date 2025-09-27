{
  description = "NixOS System Configuration Flake from tchavadar";

  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    sparse = {
      url = "github:Orca-The-Company/sparse";
      # url = "github:Orca-The-Company/sparse/sparse/talhaHavadar/unknown-commands/slice/2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-snapd = {
      url = "github:nix-community/nix-snapd";
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
      inputs.nixpkgs.follows = "nixpkgs";
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
      nix-snapd,
      nixos-raspberrypi,
      ...
    }@inputs:
    let
      mkHomeConfiguration =
        { system, username, ... }@args:
        home-manager.lib.homeManagerConfiguration (
          {
            modules = [
              ./features
              ./users.nix
              ./home.nix
            ];
            pkgs = import nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
              };
            };
            extraSpecialArgs = {
            };

          }
          // {
            inherit (args) extraSpecialArgs;
          }
        );
      username = builtins.getEnv "NIX_MYUSER";
      system = builtins.currentSystem;
      platform = builtins.getEnv "NIX_PLATFORM";
    in
    {
      default = { };

      nixosConfigurations.nixos-ai-crawler = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          platform = "nixos-container";
          currentConfigSystem = "nixos";
        };
        modules = [
          ./features
          ./machines/nixos-container
          ./ai-crawler
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.talha.imports = [
              ./home/talha
              ./home.nix
            ];
            home-manager.extraSpecialArgs = {
              inherit inputs;
              system = "x86_64-linux";
              platform = "nixos-container";
              currentConfigSystem = "home";
            };
            home-manager.backupFileExtension = "backup";
          }
        ];
      };

      nixosConfigurations.blog = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          platform = "nixos";
          currentConfigSystem = "nixos";
        };
        modules = [
          ./features
          ./machines/vm-server
          ./blogging
        ];
      };

      nixosConfigurations.surface = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          inherit username;
          platform = "nixos";
          currentConfigSystem = "nixos";
        };
        modules = [
          ./features
          ./yubikey.nix
          ./users.nix
          nixos-hardware.nixosModules.microsoft-surface-common
          nixos-hardware.nixosModules.microsoft-surface-pro-intel
          nix-snapd.nixosModules.default
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

      nixosConfigurations.pi-dev = nixos-raspberrypi.lib.nixosSystem {
        inherit system;
        specialArgs = inputs // {
          inherit inputs;
          inherit username;
          platform = "nixos";
          currentConfigSystem = "nixos";
        };
        modules = [
          ./features
          ./yubikey.nix
          ./home/talha
          nix-snapd.nixosModules.default
          (import ./machines/pi-dev)
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.talha.imports = [
              ./home/talha
              ./home.nix
            ];
            home-manager.extraSpecialArgs = {
              inherit inputs;
              inherit system;
              platform = "nixos-container";
              currentConfigSystem = "home";
            };
            home-manager.backupFileExtension = "backup";
          }
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
          ./features
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

      darwinConfigurations.macpro = darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit username;
          platform = "macos";
          currentConfigSystem = "darwin";
        };
        modules = [
          ./machines/macpro
          (
            { ... }:
            {
              users.users.talha = {
                name = "talha";
                home = "/Users/talha";
              };
              users.users.benis = {
                name = "benis";
                home = "/Users/benis";
              };
            }
          )
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
              platform = "macos";
              currentConfigSystem = "home";
            };
            home-manager.users.benis.imports = [
              ./home/benis
              ./home.nix
            ];
            home-manager.users.talha.imports = [
              ./home/talha
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
