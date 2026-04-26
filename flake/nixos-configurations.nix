{ inputs, ... }:
let
  system = "x86_64-linux";
  inherit (inputs.nixpkgs) lib;
  hosts = import ../hosts;

  mkHomeManagerModule = username: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = { inherit (inputs) plasma-manager; };
    home-manager.users.${username} = import ../home/${username}/home.nix;
  };

  mkHost = hostname: { username, profile }:
    lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit hostname username;
        inherit (inputs) import-tree;
      };
      modules = [
        profile
        ../hosts/${hostname}
        inputs.home-manager.nixosModules.home-manager
        (mkHomeManagerModule username)
      ];
    };

  installerSystem = lib.nixosSystem {
    inherit system;
    specialArgs = {
      inherit (inputs) self import-tree;
    };
    modules = [
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
      ../installer/default.nix
    ];
  };
in
{
  systems = [ system ];

  flake = {
    nixosConfigurations =
      lib.mapAttrs mkHost hosts
      // {
        installer = installerSystem;
      };

    packages.${system}.installer-iso = installerSystem.config.system.build.isoImage;
  };
}
