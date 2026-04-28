{ inputs, ... }:
let
  defaultSystem = "x86_64-linux";
  inherit (inputs.nixpkgs) lib;

  moduleCatalog = {
    hardware = {
      cpuAmd = ../modules/hardware/cpu-amd.nix;
      cpuIntel = ../modules/hardware/cpu-intel.nix;
      nvidia = ../modules/hardware/nvidia.nix;
      tpmLuks = ../modules/hardware/tpm-luks.nix;
    };

    systemSoftware = {
      audioPipewire = ../modules/system/audio-pipewire.nix;
      base = ../modules/system/base.nix;
      desktopHyprland = ../modules/system/desktop-hyprland.nix;
      desktopKde = ../modules/system/desktop-kde.nix;
      desktopServices = ../modules/system/desktop-services.nix;
      displaySddm = ../modules/system/display-sddm.nix;
      flatpak = ../modules/system/flatpak.nix;
      fonts = ../modules/system/fonts.nix;
      networking = ../modules/system/networking.nix;
      wallpaper = ../modules/system/wallpaper.nix;
    };

    userSoftware = {
      onepassword = ../modules/user/onepassword.nix;
      steam = ../modules/user/steam.nix;
    };
  };

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
      hardware ? [ ],
      systemSoftware ? [ moduleCatalog.systemSoftware.base ],
      userSoftware ? [ ],
      homeModule ? null,
      extraModules ? [ ],
      specialArgs ? { },
      system ? defaultSystem,
    }:
    lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit hostname username;
      } // specialArgs;
      modules = hardware
      ++ systemSoftware
      ++ userSoftware
      ++ [
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
  systems = [ defaultSystem ];

  flake = {
    lib = {
      inherit mkDendriticHost moduleCatalog;
    };

    nixosModules = {
      default = moduleCatalog.systemSoftware.base;
      hardware-cpu-amd = moduleCatalog.hardware.cpuAmd;
      hardware-cpu-intel = moduleCatalog.hardware.cpuIntel;
      hardware-nvidia = moduleCatalog.hardware.nvidia;
      hardware-tpm-luks = moduleCatalog.hardware.tpmLuks;
      system-audio-pipewire = moduleCatalog.systemSoftware.audioPipewire;
      system-base = moduleCatalog.systemSoftware.base;
      system-desktop-hyprland = moduleCatalog.systemSoftware.desktopHyprland;
      system-desktop-kde = moduleCatalog.systemSoftware.desktopKde;
      system-desktop-services = moduleCatalog.systemSoftware.desktopServices;
      system-display-sddm = moduleCatalog.systemSoftware.displaySddm;
      system-flatpak = moduleCatalog.systemSoftware.flatpak;
      system-fonts = moduleCatalog.systemSoftware.fonts;
      system-networking = moduleCatalog.systemSoftware.networking;
      system-wallpaper = moduleCatalog.systemSoftware.wallpaper;
      user-onepassword = moduleCatalog.userSoftware.onepassword;
      user-steam = moduleCatalog.userSoftware.steam;
      installer = ../installer/default.nix;
    };
  };
}
