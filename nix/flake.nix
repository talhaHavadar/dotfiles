{
  description = "NixOS System Configuration Flake from tchavadar";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
    home-manager = {
        url = "github:nix-community/home-manager/release-24.05";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs:
    let
      # Systems supported
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "aarch64-darwin" # 64-bit ARM macOS
      ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs allSystems (system:
          f {
            pkgs = import nixpkgs { inherit system; };
	  });
      mkHomeConfiguration = {system, ... }@args: home-manager.lib.homeManagerConfiguration( rec {
	modules = [ ./home.nix ];
	pkgs = nixpkgs.legacyPackages.${system}; 
      });
    in {


      homeConfigurations.ubuntu = mkHomeConfiguration {
        system = "x86_64-linux";
      };
      homeConfigurations.pc = mkHomeConfiguration {
        system = "x86_64-linux";
      };
      homeConfigurations.macArm = mkHomeConfiguration {
        system = "aarch64-darwin";
      };

      devShells = forAllSystems({pkgs}: {
        default = pkgs.mkShell {
          packages = [
	    pkgs.cowsay
	  ];
        };
      });

    };
}
