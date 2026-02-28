{
  description = "NixOS config (dendritic)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, plasma-manager, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      mkHost = { hostname, username }:
        lib.nixosSystem {
          inherit system;
          specialArgs = { inherit hostname username; };
          modules = [
            ./hosts/${hostname}
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit plasma-manager; };
              home-manager.users.${username} = import ./home/${username}/home.nix;
            }
          ];
        };

      installerSystem = lib.nixosSystem {
        inherit system;
        specialArgs = { inherit self; };
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma6.nix"
          ./installer/default.nix
        ];
      };
    in {
      nixosConfigurations = {
        taipei-linux = mkHost {
          hostname = "taipei-linux";
          username = "johnbarney";
        };

        taipei-installer = installerSystem;
      };

      packages.${system}.taipei-installer-iso = installerSystem.config.system.build.isoImage;
    };
}
