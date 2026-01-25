{
  description = "NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";

      # Create pkgs with unstable overlay
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # Unstable packages overlay
      unstableOverlay = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };

      # Helper function to create a NixOS system configuration
      mkHost = { hostname, userConfig }: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          # Apply unstable overlay
          { nixpkgs.overlays = [ unstableOverlay ]; }

          # Host configuration
          ./hosts/${hostname}

          # Home Manager as a NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.sggutier = { ... }: {
              imports = [
                ./home/sggutier
                userConfig
              ];
            };
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        enkidu = mkHost {
          hostname = "enkidu";
          userConfig = ./home/sggutier/enkidu.nix;
        };

        wall-e = mkHost {
          hostname = "wall-e";
          userConfig = ./home/sggutier/wall-e.nix;
        };
      };

      # Standalone home-manager configuration (optional, for non-NixOS systems)
      homeConfigurations = {
        "sggutier" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home/sggutier ];
          extraSpecialArgs = { inherit inputs; };
        };
      };
    };
}
