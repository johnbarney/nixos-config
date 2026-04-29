{ inputs, ... }:
let
  defaultSystem = "x86_64-linux";
  inherit (inputs.nixpkgs) lib;
  catalogDocs = import ../lib/catalog-docs.nix;

  moduleCatalog = rec {
    hardware = {
      cpuAmd = ../modules/hardware/cpu-amd.nix;
      cpuIntel = ../modules/hardware/cpu-intel.nix;
      graphicsAmd = ../modules/hardware/graphics-amd.nix;
      graphicsIntel = ../modules/hardware/graphics-intel.nix;
      graphicsNvidia = ../modules/hardware/graphics-nvidia.nix;
      tpmLuks = ../modules/hardware/tpm-luks.nix;
    };

    systemSoftware = {
      audioPipewire = ../modules/system/audio-pipewire.nix;
      avahi = ../modules/system/avahi.nix;
      base = ../modules/system/base.nix;
      bluetooth = ../modules/system/bluetooth.nix;
      dconf = ../modules/system/dconf.nix;
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
      firewall = ../modules/system/firewall.nix;
      flatpak = ../modules/system/flatpak.nix;
      fonts = ../modules/system/fonts.nix;
      firmwareUpdates = ../modules/system/firmware-updates.nix;
      networking = ../modules/system/networking.nix;
      networkShares = ../modules/system/network-shares.nix;
      networkmanager = ../modules/system/networkmanager.nix;
      powerManagement = ../modules/system/power-management.nix;
      printing = ../modules/system/printing.nix;
      storageDesktop = ../modules/system/storage-desktop.nix;
      timeSync = ../modules/system/time-sync.nix;
      wallpaper = ../modules/system/wallpaper.nix;
    };

    userSoftware = {
      chromium = ../modules/user/chromium.nix;
      firefox = ../modules/user/firefox.nix;
      onepassword = ../modules/user/onepassword.nix;
      steam = ../modules/user/steam.nix;
    };

    homeSoftware = {
      base = ../modules/home/base.nix;
      defaultApps = ../modules/home/default-apps.nix;
      defaultAppsGnome = ../modules/home/default-apps-gnome.nix;
      defaultAppsHyprland = ../modules/home/default-apps-hyprland.nix;
      defaultAppsKde = ../modules/home/default-apps-kde.nix;
      gnomeBreezeDark = ../modules/home/gnome-breeze-dark.nix;
      gtkQtBreezeDark = ../modules/home/gtk-qt-breeze-dark.nix;
      hyprlandBar = ../modules/home/hyprland-bar.nix;
      hyprlandFull = ../modules/home/hyprland-full.nix;
      hyprlandLauncher = ../modules/home/hyprland-launcher.nix;
      hyprlandNotifications = ../modules/home/hyprland-notifications.nix;
      hyprlandSession = ../modules/home/hyprland-session.nix;
      hyprlandWallpaper = ../modules/home/hyprland-wallpaper.nix;
      plasmaBreezeDark = ../modules/home/plasma-breeze-dark.nix;
      ssh = ../modules/home/ssh.nix;
      sshOnepasswordAgent = ../modules/home/ssh-onepassword-agent.nix;
      terminalKitty = ../modules/home/terminal-kitty.nix;
    };

    metaModules = {
      kde = {
        systemSoftware = with systemSoftware; [
          desktopKdeFull
          fonts
        ];

        userSoftware = with userSoftware; [
          chromium
        ];

        homeSoftware = with homeSoftware; [
          defaultAppsKde
          gtkQtBreezeDark
          plasmaBreezeDark
        ];
      };

      gnome = {
        systemSoftware = with systemSoftware; [
          desktopGnomeFull
          fonts
        ];

        userSoftware = with userSoftware; [
          firefox
        ];

        homeSoftware = with homeSoftware; [
          defaultAppsGnome
          gnomeBreezeDark
        ];
      };

      hyprland = {
        systemSoftware = with systemSoftware; [
          desktopHyprland
          fonts
        ];

        userSoftware = with userSoftware; [
          chromium
        ];

        homeSoftware = with homeSoftware; [
          defaultAppsHyprland
          gtkQtBreezeDark
          hyprlandFull
          terminalKitty
        ];
      };

      onepassword = {
        userSoftware = with userSoftware; [
          onepassword
        ];

        homeSoftware = with homeSoftware; [
          sshOnepasswordAgent
        ];
      };
    };
  };

  emptyMetaModule = {
    hardware = [ ];
    systemSoftware = [ ];
    userSoftware = [ ];
    homeSoftware = [ ];
  };

  mergeMetaModules = metaModules:
    lib.foldl'
      (acc: metaModule:
        let
          meta = emptyMetaModule // metaModule;
        in
        {
          hardware = acc.hardware ++ meta.hardware;
          systemSoftware = acc.systemSoftware ++ meta.systemSoftware;
          userSoftware = acc.userSoftware ++ meta.userSoftware;
          homeSoftware = acc.homeSoftware ++ meta.homeSoftware;
        })
      emptyMetaModule
      metaModules;

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
      metaModules ? [ ],
      hardware ? [ ],
      systemSoftware ? [ ],
      userSoftware ? [ ],
      homeSoftware ? [ ],
      homeModule ? null,
      extraModules ? [ ],
      specialArgs ? { },
      system ? defaultSystem,
    }:
    let
      metaSoftware = mergeMetaModules metaModules;
      finalHardware = metaSoftware.hardware ++ hardware;
      mergedSystemSoftware = metaSoftware.systemSoftware ++ systemSoftware;
      finalSystemSoftware =
        if mergedSystemSoftware == [ ] then
          [ moduleCatalog.systemSoftware.base ]
        else
          mergedSystemSoftware;
      finalUserSoftware = metaSoftware.userSoftware ++ userSoftware;
      finalHomeSoftware = metaSoftware.homeSoftware ++ homeSoftware;
    in
    lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit hostname username;
      } // specialArgs;
      modules = finalHardware
      ++ finalSystemSoftware
      ++ finalUserSoftware
      ++ [
        hostModule
      ]
      ++ lib.optionals (homeModule != null || finalHomeSoftware != [ ]) [
        inputs.home-manager.nixosModules.home-manager
        (mkHomeManagerModule {
          inherit username homeModule;
          homeSoftware = finalHomeSoftware;
        })
      ]
      ++ extraModules;
    };

in
{
  systems = [ defaultSystem ];

  flake = {
    lib = {
      inherit catalogDocs mkDendriticHost mergeMetaModules moduleCatalog;
    };

    nixosModules = {
      default = moduleCatalog.systemSoftware.base;
      hardware-cpu-amd = moduleCatalog.hardware.cpuAmd;
      hardware-cpu-intel = moduleCatalog.hardware.cpuIntel;
      hardware-graphics-amd = moduleCatalog.hardware.graphicsAmd;
      hardware-graphics-intel = moduleCatalog.hardware.graphicsIntel;
      hardware-graphics-nvidia = moduleCatalog.hardware.graphicsNvidia;
      hardware-tpm-luks = moduleCatalog.hardware.tpmLuks;
      system-audio-pipewire = moduleCatalog.systemSoftware.audioPipewire;
      system-avahi = moduleCatalog.systemSoftware.avahi;
      system-base = moduleCatalog.systemSoftware.base;
      system-bluetooth = moduleCatalog.systemSoftware.bluetooth;
      system-dconf = moduleCatalog.systemSoftware.dconf;
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
      system-firewall = moduleCatalog.systemSoftware.firewall;
      system-flatpak = moduleCatalog.systemSoftware.flatpak;
      system-fonts = moduleCatalog.systemSoftware.fonts;
      system-firmware-updates = moduleCatalog.systemSoftware.firmwareUpdates;
      system-networking = moduleCatalog.systemSoftware.networking;
      system-network-shares = moduleCatalog.systemSoftware.networkShares;
      system-networkmanager = moduleCatalog.systemSoftware.networkmanager;
      system-power-management = moduleCatalog.systemSoftware.powerManagement;
      system-printing = moduleCatalog.systemSoftware.printing;
      system-storage-desktop = moduleCatalog.systemSoftware.storageDesktop;
      system-time-sync = moduleCatalog.systemSoftware.timeSync;
      system-wallpaper = moduleCatalog.systemSoftware.wallpaper;
      user-chromium = moduleCatalog.userSoftware.chromium;
      user-firefox = moduleCatalog.userSoftware.firefox;
      user-onepassword = moduleCatalog.userSoftware.onepassword;
      user-steam = moduleCatalog.userSoftware.steam;
      installer = ../installer/default.nix;
    };

    homeModules = {
      base = moduleCatalog.homeSoftware.base;
      default-apps = moduleCatalog.homeSoftware.defaultApps;
      default-apps-gnome = moduleCatalog.homeSoftware.defaultAppsGnome;
      default-apps-hyprland = moduleCatalog.homeSoftware.defaultAppsHyprland;
      default-apps-kde = moduleCatalog.homeSoftware.defaultAppsKde;
      gnome-breeze-dark = moduleCatalog.homeSoftware.gnomeBreezeDark;
      gtk-qt-breeze-dark = moduleCatalog.homeSoftware.gtkQtBreezeDark;
      hyprland-bar = moduleCatalog.homeSoftware.hyprlandBar;
      hyprland-full = moduleCatalog.homeSoftware.hyprlandFull;
      hyprland-launcher = moduleCatalog.homeSoftware.hyprlandLauncher;
      hyprland-notifications = moduleCatalog.homeSoftware.hyprlandNotifications;
      hyprland-session = moduleCatalog.homeSoftware.hyprlandSession;
      hyprland-wallpaper = moduleCatalog.homeSoftware.hyprlandWallpaper;
      plasma-breeze-dark = moduleCatalog.homeSoftware.plasmaBreezeDark;
      ssh = moduleCatalog.homeSoftware.ssh;
      ssh-onepassword-agent = moduleCatalog.homeSoftware.sshOnepasswordAgent;
      terminal-kitty = moduleCatalog.homeSoftware.terminalKitty;
    };
  };
}
