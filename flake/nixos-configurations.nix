{ inputs, ... }:
let
  defaultSystem = "x86_64-linux";
  inherit (inputs.nixpkgs) lib;

  moduleCatalog = {
    hardware = {
      cpuAmd = ../modules/hardware/cpu-amd.nix;
      cpuIntel = ../modules/hardware/cpu-intel.nix;
      graphicsAmd = ../modules/hardware/graphics-amd.nix;
      nvidia = ../modules/hardware/nvidia.nix;
      tpmLuks = ../modules/hardware/tpm-luks.nix;
    };

    systemSoftware = {
      audioPipewire = ../modules/system/audio-pipewire.nix;
      base = ../modules/system/base.nix;
      desktopGnome = ../modules/system/desktop-gnome.nix;
      desktopGnomeApps = ../modules/system/desktop-gnome-apps.nix;
      desktopGnomeFull = ../modules/system/desktop-gnome-full.nix;
      desktopHyprland = ../modules/system/desktop-hyprland.nix;
      desktopKde = ../modules/system/desktop-kde.nix;
      desktopKdeApps = ../modules/system/desktop-kde-apps.nix;
      desktopKdeFull = ../modules/system/desktop-kde-full.nix;
      desktopServices = ../modules/system/desktop-services.nix;
      displayGdm = ../modules/system/display-gdm.nix;
      displaySddm = ../modules/system/display-sddm.nix;
      flatpak = ../modules/system/flatpak.nix;
      fonts = ../modules/system/fonts.nix;
      networking = ../modules/system/networking.nix;
      wallpaper = ../modules/system/wallpaper.nix;
    };

    userSoftware = {
      chromium = ../modules/user/chromium.nix;
      heroic = ../modules/user/heroic.nix;
      onepassword = ../modules/user/onepassword.nix;
      steam = ../modules/user/steam.nix;
      vscode = ../modules/user/vscode.nix;
    };

    homeSoftware = {
      base = ../modules/home/base.nix;
      hyprlandFull = ../modules/home/hyprland-full.nix;
      plasmaBreezeDark = ../modules/home/plasma-breeze-dark.nix;
      shellZsh = ../modules/home/shell-zsh.nix;
      sshOnepasswordAgent = ../modules/home/ssh-onepassword-agent.nix;
      terminalKitty = ../modules/home/terminal-kitty.nix;
      themeBreezeDark = ../modules/home/theme-breeze-dark.nix;
      vscode = ../modules/home/vscode.nix;
    };
  };

  mkHomeManagerModule = { username, homeModule, homeSoftware }: {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.extraSpecialArgs = { inherit (inputs) plasma-manager; };
    home-manager.users.${username} = {
      imports = homeSoftware ++ lib.optionals (homeModule != null) [
        homeModule
      ];
    };
  };

  mkDendriticHost =
    {
      hostname,
      username,
      hostModule,
      hardware ? [ ],
      systemSoftware ? [ moduleCatalog.systemSoftware.base ],
      userSoftware ? [ ],
      homeSoftware ? [ ],
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
      ++ lib.optionals (homeModule != null || homeSoftware != [ ]) [
        inputs.home-manager.nixosModules.home-manager
        (mkHomeManagerModule { inherit username homeModule homeSoftware; })
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
      hardware-graphics-amd = moduleCatalog.hardware.graphicsAmd;
      hardware-nvidia = moduleCatalog.hardware.nvidia;
      hardware-tpm-luks = moduleCatalog.hardware.tpmLuks;
      system-audio-pipewire = moduleCatalog.systemSoftware.audioPipewire;
      system-base = moduleCatalog.systemSoftware.base;
      system-desktop-gnome = moduleCatalog.systemSoftware.desktopGnome;
      system-desktop-gnome-apps = moduleCatalog.systemSoftware.desktopGnomeApps;
      system-desktop-gnome-full = moduleCatalog.systemSoftware.desktopGnomeFull;
      system-desktop-hyprland = moduleCatalog.systemSoftware.desktopHyprland;
      system-desktop-kde = moduleCatalog.systemSoftware.desktopKde;
      system-desktop-kde-apps = moduleCatalog.systemSoftware.desktopKdeApps;
      system-desktop-kde-full = moduleCatalog.systemSoftware.desktopKdeFull;
      system-desktop-services = moduleCatalog.systemSoftware.desktopServices;
      system-display-gdm = moduleCatalog.systemSoftware.displayGdm;
      system-display-sddm = moduleCatalog.systemSoftware.displaySddm;
      system-flatpak = moduleCatalog.systemSoftware.flatpak;
      system-fonts = moduleCatalog.systemSoftware.fonts;
      system-networking = moduleCatalog.systemSoftware.networking;
      system-wallpaper = moduleCatalog.systemSoftware.wallpaper;
      user-chromium = moduleCatalog.userSoftware.chromium;
      user-heroic = moduleCatalog.userSoftware.heroic;
      user-onepassword = moduleCatalog.userSoftware.onepassword;
      user-steam = moduleCatalog.userSoftware.steam;
      user-vscode = moduleCatalog.userSoftware.vscode;
      installer = ../installer/default.nix;
    };

    homeModules = {
      base = moduleCatalog.homeSoftware.base;
      hyprland-full = moduleCatalog.homeSoftware.hyprlandFull;
      plasma-breeze-dark = moduleCatalog.homeSoftware.plasmaBreezeDark;
      shell-zsh = moduleCatalog.homeSoftware.shellZsh;
      ssh-onepassword-agent = moduleCatalog.homeSoftware.sshOnepasswordAgent;
      terminal-kitty = moduleCatalog.homeSoftware.terminalKitty;
      theme-breeze-dark = moduleCatalog.homeSoftware.themeBreezeDark;
      vscode = moduleCatalog.homeSoftware.vscode;
    };
  };
}
