{
  description = "NixOS and Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    helium-wv.url = "github:jcdickinson/helium-wv";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-master, home-manager, helium-wv, ... }@inputs:
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

      # nixpkgs master overlay, for packages that need to track upstream
      # ahead of even nixos-unstable (e.g. immich on wall-e)
      masterOverlay = final: prev: {
        master = import nixpkgs-master {
          inherit system;
          config.allowUnfree = true;
        };
      };

      # Helper function to create a NixOS system configuration
      mkHost = { hostname, userConfig, extraModules ? [] }: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          # Apply unstable overlay
          { nixpkgs.overlays = [ unstableOverlay masterOverlay ]; }

          # Host configuration
          ./hosts/${hostname}
        ] ++ extraModules ++ [

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
          extraModules = [ inputs."sops-nix".nixosModules.sops ];
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
