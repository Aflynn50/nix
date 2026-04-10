{
  description = "Cross-platform nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    home-manager,
  }: let
    mkDarwinSystem = {
      username,
      hostDarwinModule,
      hostHomeModule,
    }:
      nix-darwin.lib.darwinSystem {
        modules = [
          ./darwin/configuration.nix
          hostDarwinModule
          home-manager.darwinModules.home-manager
          {
            # Automatically append old files to be replaced with .before-home-manager
            home-manager.backupFileExtension = "before-home-manager";
            home-manager.users.${username} = {...}: {
              imports = [./home/home.nix hostHomeModule];
            };
            # Set Git commit hash for darwin-version. The self property is only
            # available here, so just plonk this here for now.
            system.configurationRevision = self.rev or self.dirtyRev or null;
          }
        ];
      };

    mkHomeConfiguration = {
      system,
      username,
      hostHomeModule,
    }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ./home/home.nix
          hostHomeModule
          {
            home.username = username;
            home.homeDirectory = "/home/${username}";
          }
        ];
      };
  in {
    darwinConfigurations = {
      "842f57432ec3" = mkDarwinSystem {
        username = "alasflyn";
        hostDarwinModule = ./darwin/hosts/aws.nix;
        hostHomeModule = ./home/hosts/aws.nix;
      }; # AWS
      "GC9VDX0C4R" = mkDarwinSystem {
        username = "alastai.flynn";
        hostDarwinModule = ./darwin/hosts/s1.nix;
        hostHomeModule = ./home/hosts/s1.nix;
      }; # S1
    };

    homeConfigurations = {
      # Standalone home-manager for Linux. Run: home-manager switch --flake .
      "aflynn" = mkHomeConfiguration {
        system = "x86_64-linux";
        username = "aflynn";
        hostHomeModule = {};
      };
    };
  };
}
