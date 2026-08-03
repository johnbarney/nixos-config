{
  description = "Reusable NixOS and Home Manager modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      plasma-manager,
      ...
    }:
    let
      system = "x86_64-linux";

      nixosModules = {
        default = ./profiles/system/workstation.nix;
        workstation = ./profiles/system/workstation.nix;
        desktop-gnome = ./profiles/system/gnome.nix;
        desktop-hyprland = ./profiles/system/hyprland.nix;
        desktop-kde = ./profiles/system/kde.nix;

        hardware-cpu-amd = ./modules/hardware/cpu-amd.nix;
        hardware-cpu-intel = ./modules/hardware/cpu-intel.nix;
        hardware-graphics-amd = ./modules/hardware/graphics-amd.nix;
        hardware-graphics-intel = ./modules/hardware/graphics-intel.nix;
        hardware-graphics-nvidia = ./modules/hardware/graphics-nvidia.nix;
        hardware-tpm-luks = ./modules/hardware/tpm-luks.nix;

        display-gdm = ./modules/system/display-gdm.nix;
        display-sddm = ./modules/system/display-sddm.nix;
        onepassword = ./modules/user/onepassword.nix;
        steam = ./modules/user/steam.nix;
        home-manager = home-manager.nixosModules.home-manager;
        installer = ./installer/default.nix;
      };

      kdeHomeProfile = {
        imports = [
          plasma-manager.homeModules.plasma-manager
          ./profiles/home/kde.nix
        ];
      };

      homeModules = {
        default = ./modules/home/base.nix;
        base = ./modules/home/base.nix;
        desktop-gnome = ./profiles/home/gnome.nix;
        desktop-hyprland = ./profiles/home/hyprland.nix;
        desktop-kde = kdeHomeProfile;
        onepassword = ./modules/home/ssh-onepassword-agent.nix;
      };

      exampleSystem = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          hostname = "example";
          username = "alice";
        };
        modules = [
          nixosModules.workstation
          nixosModules.desktop-kde
          nixosModules.display-sddm
          nixosModules.hardware-cpu-amd
          nixosModules.hardware-graphics-amd
          nixosModules.home-manager
          ./examples/basic/hosts/example
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.alice.imports = [
              homeModules.default
              homeModules.desktop-kde
              ./examples/basic/home/alice/home.nix
            ];
          }
        ];
      };

      installerSystem = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
          nixosModules.installer
        ];
      };
    in
    {
      inherit homeModules nixosModules;

      checks.${system} = {
        example = exampleSystem.config.system.build.toplevel;
        installer = installerSystem.config.system.build.toplevel;
      };

      nixosConfigurations.installer = installerSystem;

      packages.${system}.installer-iso = installerSystem.config.system.build.isoImage;

      templates.default = {
        path = ./examples/basic;
        description = "A small NixOS host using the reusable modules in this flake";
      };
    };
}
