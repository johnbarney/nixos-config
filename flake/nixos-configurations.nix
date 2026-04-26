{ inputs, ... }:
let
  system = "x86_64-linux";
  inherit (inputs.nixpkgs) lib;

  mkHomeManagerModule = { username, homeModule }: {
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
      profile ? ../profiles/desktop.nix,
      homeModule ? null,
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
      ]
      ++ lib.optionals (homeModule != null) [
        inputs.home-manager.nixosModules.home-manager
        (mkHomeManagerModule { inherit username homeModule; })
      ]
      ++ extraModules;
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
      cpu-amd = ../modules/nixos/cpu-amd.nix;
      cpu-intel = ../modules/nixos/cpu-intel.nix;
      desktop = ../profiles/desktop.nix;
      desktop-nvidia = ../profiles/desktop-nvidia.nix;
      installer = ../installer/default.nix;
    };
  };
}
