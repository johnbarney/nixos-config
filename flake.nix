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

        # Granular modules remain available for hosts that intentionally compose
        # something other than the opinionated profiles above.
        system-audio-pipewire = ./modules/system/audio-pipewire.nix;
        system-avahi = ./modules/system/avahi.nix;
        system-base = ./modules/system/base.nix;
        system-bluetooth = ./modules/system/bluetooth.nix;
        system-dconf = ./modules/system/dconf.nix;
        system-desktop-gnome = ./modules/system/desktop-gnome.nix;
        system-desktop-gnome-apps = ./modules/system/desktop-gnome-apps.nix;
        system-desktop-gnome-full = ./modules/system/desktop-gnome-full.nix;
        system-desktop-hyprland = ./modules/system/desktop-hyprland.nix;
        system-desktop-kde = ./modules/system/desktop-kde.nix;
        system-desktop-kde-apps = ./modules/system/desktop-kde-apps.nix;
        system-desktop-kde-full = ./modules/system/desktop-kde-full.nix;
        system-desktop-services = ./modules/system/desktop-services.nix;
        system-display-gdm = ./modules/system/display-gdm.nix;
        system-display-sddm = ./modules/system/display-sddm.nix;
        system-firewall = ./modules/system/firewall.nix;
        system-firmware-updates = ./modules/system/firmware-updates.nix;
        system-flatpak = ./modules/system/flatpak.nix;
        system-fonts = ./modules/system/fonts.nix;
        system-network-shares = ./modules/system/network-shares.nix;
        system-networking = ./modules/system/networking.nix;
        system-networkmanager = ./modules/system/networkmanager.nix;
        system-power-management = ./modules/system/power-management.nix;
        system-printing = ./modules/system/printing.nix;
        system-storage-desktop = ./modules/system/storage-desktop.nix;
        system-time-sync = ./modules/system/time-sync.nix;
        system-wallpaper = ./modules/system/wallpaper.nix;
        user-chromium = ./modules/user/chromium.nix;
        user-firefox = ./modules/user/firefox.nix;
        user-onepassword = ./modules/user/onepassword.nix;
        user-steam = ./modules/user/steam.nix;
      };

      plasmaThemeModule = {
        imports = [
          plasma-manager.homeModules.plasma-manager
          ./modules/home/plasma-breeze-dark.nix
        ];
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

        default-apps = ./modules/home/default-apps.nix;
        default-apps-gnome = ./modules/home/default-apps-gnome.nix;
        default-apps-hyprland = ./modules/home/default-apps-hyprland.nix;
        default-apps-kde = ./modules/home/default-apps-kde.nix;
        gnome-breeze-dark = ./modules/home/gnome-breeze-dark.nix;
        gtk-qt-breeze-dark = ./modules/home/gtk-qt-breeze-dark.nix;
        hyprland-bar = ./modules/home/hyprland-bar.nix;
        hyprland-full = ./modules/home/hyprland-full.nix;
        hyprland-launcher = ./modules/home/hyprland-launcher.nix;
        hyprland-notifications = ./modules/home/hyprland-notifications.nix;
        hyprland-session = ./modules/home/hyprland-session.nix;
        hyprland-wallpaper = ./modules/home/hyprland-wallpaper.nix;
        plasma-breeze-dark = plasmaThemeModule;
        ssh = ./modules/home/ssh.nix;
        ssh-onepassword-agent = ./modules/home/ssh-onepassword-agent.nix;
        terminal-kitty = ./modules/home/terminal-kitty.nix;
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
    in
    {
      inherit homeModules nixosModules;

      checks.${system}.example = exampleSystem.config.system.build.toplevel;

      templates.default = {
        path = ./examples/basic;
        description = "A small NixOS host using the reusable modules in this flake";
      };
    };
}
