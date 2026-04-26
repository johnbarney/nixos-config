{ inputs, ... }:
let
  system = "x86_64-linux";
  inherit (inputs.nixpkgs) lib;
  hosts = import ../hosts;

  mkHomeManagerModule = { username, homeModule ? ../home/${username}/home.nix }: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = { inherit (inputs) plasma-manager; };
    home-manager.users.${username} = import homeModule;
  };

  mkDendriticHost =
    {
      hostname,
      username,
      hostModule,
      profile ? ../profiles/desktop-nvidia.nix,
      homeModule ? ../home/${username}/home.nix,
      extraModules ? [ ],
      specialArgs ? { },
      system ? "x86_64-linux",
    }:
    lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit hostname username;
        inherit (inputs) import-tree;
      } // specialArgs;
      modules = [
        profile
        hostModule
        inputs.home-manager.nixosModules.home-manager
        (mkHomeManagerModule { inherit username homeModule; })
      ] ++ extraModules;
    };

  mkHost = hostname: { username, profile }:
    mkDendriticHost {
      inherit hostname username profile;
      hostModule = ../hosts/${hostname};
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
    lib = {
      inherit mkDendriticHost;
    };

    nixosModules = {
      default = ../modules/nixos;
      dendritic = ../modules/nixos;
      desktop-nvidia = ../profiles/desktop-nvidia.nix;
    };

    templates = {
      hosts = {
        path = ../templates/private-hosts;
        description = "Host flake consuming the dendritic public base";
      };

      private-hosts = {
        path = ../templates/private-hosts;
        description = "Alias for templates.hosts";
      };
    };

    nixosConfigurations =
      lib.mapAttrs mkHost hosts
      // {
        installer = installerSystem;
      };

    packages.${system}.installer-iso = installerSystem.config.system.build.isoImage;
  };
}
