{
  description = "Example NixOS hosts using johnbarney/nixos-config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-config = {
      url = "github:johnbarney/nixos-config";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, nixos-config, ... }:
    let
      system = "x86_64-linux";
      username = "alice";

      mkHost =
        {
          hostname,
          systemProfile,
          displayProfile,
          homeProfile,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit hostname username; };
          modules = [
            nixos-config.nixosModules.workstation
            systemProfile
            displayProfile
            nixos-config.nixosModules.hardware-cpu-amd
            nixos-config.nixosModules.hardware-graphics-amd
            nixos-config.nixosModules.home-manager
            ./hosts/example
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username}.imports = [
                nixos-config.homeModules.default
                homeProfile
                ./home/alice/home.nix
              ];
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        fedora-kde = mkHost {
          hostname = "fedora-kde";
          systemProfile = nixos-config.nixosModules.desktop-fedora-kde;
          displayProfile = nixos-config.nixosModules.display-sddm;
          homeProfile = nixos-config.homeModules.desktop-fedora-kde;
        };

        fedora-gnome = mkHost {
          hostname = "fedora-gnome";
          systemProfile = nixos-config.nixosModules.desktop-fedora-gnome;
          displayProfile = nixos-config.nixosModules.display-gdm;
          homeProfile = nixos-config.homeModules.desktop-fedora-gnome;
        };

        omarchy = mkHost {
          hostname = "omarchy";
          systemProfile = nixos-config.nixosModules.desktop-omarchy;
          displayProfile = nixos-config.nixosModules.display-sddm;
          homeProfile = nixos-config.homeModules.desktop-omarchy;
        };
      };
    };
}
