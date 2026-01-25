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
    in
    {
      nixosConfigurations = {
        enkidu = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            # Apply unstable overlay
            { nixpkgs.overlays = [ unstableOverlay ]; }

            # Host configuration
            ./hosts/enkidu

            # Home Manager as a NixOS module
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.users.sggutier = import ./home/sggutier;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
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
