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
        # Machine-role profiles.
        default = ./profiles/system/workstation.nix;
        workstation = ./profiles/system/workstation.nix;

        # Desktop-experience profiles, composed with a machine role.
        desktop-fedora-gnome = ./profiles/system/fedora-gnome.nix;
        desktop-fedora-kde = ./profiles/system/fedora-kde.nix;
        desktop-omarchy = ./profiles/system/omarchy.nix;

        hardware-cpu-amd = ./modules/hardware/cpu-amd.nix;
        hardware-cpu-intel = ./modules/hardware/cpu-intel.nix;
        hardware-graphics-amd = ./modules/hardware/graphics-amd.nix;
        hardware-graphics-intel = ./modules/hardware/graphics-intel.nix;
        hardware-graphics-nvidia = ./modules/hardware/graphics-nvidia.nix;
        hardware-tpm-luks = ./modules/hardware/tpm-luks.nix;

        display-gdm = ./modules/system/display-gdm.nix;
        display-sddm = ./modules/system/display-sddm.nix;
        gaming = ./profiles/system/gaming.nix;
        onepassword = ./modules/user/onepassword.nix;
        home-manager = home-manager.nixosModules.home-manager;
        installer = ./installer/default.nix;
      };

      fedoraKdeHomeProfile = {
        imports = [
          plasma-manager.homeModules.plasma-manager
          ./profiles/home/fedora-kde.nix
        ];
      };

      homeModules = {
        default = ./modules/home/base.nix;
        base = ./modules/home/base.nix;
        desktop-fedora-gnome = ./profiles/home/fedora-gnome.nix;
        desktop-fedora-kde = fedoraKdeHomeProfile;
        desktop-omarchy = ./profiles/home/omarchy.nix;
        onepassword = ./modules/home/ssh-onepassword-agent.nix;
      };

      mkExampleSystem =
        {
          hostname,
          systemProfile,
          displayProfile,
          homeProfile,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit hostname;
            username = "alice";
          };
          modules = [
            nixosModules.workstation
            systemProfile
            displayProfile
            nixosModules.hardware-cpu-amd
            nixosModules.hardware-graphics-amd
            nixosModules.home-manager
            ./examples/basic/hosts/example
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.alice.imports = [
                homeModules.default
                homeProfile
                ./examples/basic/home/alice/home.nix
              ];
            }
          ];
        };

      fedoraKdeExampleSystem = mkExampleSystem {
        hostname = "fedora-kde";
        systemProfile = nixosModules.desktop-fedora-kde;
        displayProfile = nixosModules.display-sddm;
        homeProfile = homeModules.desktop-fedora-kde;
      };

      fedoraGnomeExampleSystem = mkExampleSystem {
        hostname = "fedora-gnome";
        systemProfile = nixosModules.desktop-fedora-gnome;
        displayProfile = nixosModules.display-gdm;
        homeProfile = homeModules.desktop-fedora-gnome;
      };

      omarchyExampleSystem = mkExampleSystem {
        hostname = "omarchy";
        systemProfile = nixosModules.desktop-omarchy;
        displayProfile = nixosModules.display-sddm;
        homeProfile = homeModules.desktop-omarchy;
      };

      workstationBaselineCheck =
        nixosSystem:
        let
          cfg = nixosSystem.config;
        in
        assert cfg.hardware.enableRedistributableFirmware;
        assert cfg.networking.firewall.enable;
        assert cfg.nix.optimise.automatic;
        assert cfg.services.chrony.enable;
        assert cfg.services.fstrim.enable;
        assert cfg.services.fstrim.interval == "weekly";
        assert cfg.services.fwupd.enable;
        assert cfg.services.journald.storage == "persistent";
        assert cfg.services.smartd.enable;
        assert cfg.systemd.oomd.enable;
        assert cfg.systemd.oomd.enableRootSlice;
        assert cfg.systemd.oomd.enableUserSlices;
        assert cfg.zramSwap.enable;
        cfg.system.build.toplevel;

      # Keep optional capabilities honest: gaming must evaluate without a
      # machine-role profile or any vendor-specific graphics module.
      gamingCapabilitySystem = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixosModules.gaming
          {
            boot.isContainer = true;
            networking.hostName = "gaming-capability-check";
            system.stateVersion = "25.11";
          }
        ];
      };

      tpmLuksCapabilitySystem = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nixosModules.hardware-tpm-luks
          {
            boot.isContainer = true;
            networking.hostName = "tpm-luks-capability-check";
            system.stateVersion = "25.11";
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
        example-fedora-kde = workstationBaselineCheck fedoraKdeExampleSystem;
        example-fedora-gnome = fedoraGnomeExampleSystem.config.system.build.toplevel;
        example-omarchy = omarchyExampleSystem.config.system.build.toplevel;
        gaming-capability = gamingCapabilitySystem.config.system.build.toplevel;
        installer = installerSystem.config.system.build.toplevel;
        tpm-luks-capability =
          assert !tpmLuksCapabilitySystem.config.boot.initrd.luks.devices.cryptroot.allowDiscards;
          tpmLuksCapabilitySystem.config.system.build.toplevel;
      };

      nixosConfigurations.installer = installerSystem;

      packages.${system}.installer-iso = installerSystem.config.system.build.isoImage;

      templates.default = {
        path = ./examples/basic;
        description = "A small NixOS host using the reusable modules in this flake";
      };
    };
}
