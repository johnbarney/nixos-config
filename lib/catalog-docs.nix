{
  pages = [
    {
      file = "catalog.md";
      title = "Catalog Overview";
      intro = ''
        Dendritic exposes a small menu of NixOS and Home Manager modules. Host
        repos pick from these menus instead of copying large blocks of NixOS
        configuration.

        Use explicit menu items when you want exact control. Use metamodules
        when a feature naturally spans system, user, and home layers. Display
        managers stay explicit because a host should normally select exactly
        one. The catalog is curated; it is not a replacement for nixpkgs.
        Install ordinary packages directly from `pkgs` in a host or home module.
      '';
      items = [
        {
          name = "hardware";
          layer = "catalog";
          description = "Machine-specific support such as CPU microcode, graphics drivers, and TPM-backed disk unlock.";
          useWhen = "Choose these based on the physical host.";
        }
        {
          name = "systemSoftware";
          layer = "catalog";
          description = "Operating system services, desktop sessions, display managers, networking, audio, fonts, and shared wallpaper setup.";
          useWhen = "Choose these for system-wide behavior shared by all users on a host.";
        }
        {
          name = "userSoftware";
          layer = "catalog";
          description = "Curated system-installed user applications.";
          useWhen = "Choose these from the app menu when the host should provide a curated application system-wide. For ordinary packages, install from `pkgs` directly in your host or home module.";
        }
        {
          name = "homeSoftware";
          layer = "catalog";
          description = "Home Manager modules for per-user tools, shell defaults, SSH, editor settings, terminal settings, and desktop personalization.";
          useWhen = "Choose these for settings that belong to a specific user account.";
        }
        {
          name = "metaModules";
          layer = "catalog";
          description = "Cross-menu bundles for features that are awkward to express in only one layer, such as a desktop environment plus matching Home Manager settings.";
          useWhen = "Use these for coherent features that span system, user, and home menus. Select display managers separately from `systemSoftware`.";
        }
      ];
    }
    {
      file = "hardware.md";
      title = "Hardware Modules";
      intro = "Hardware modules describe physical machine support. Most hosts should choose one CPU module and one graphics module.";
      items = [
        {
          name = "cpuAmd";
          layer = "hardware";
          description = "Enables AMD CPU microcode updates.";
          useWhen = "Use on hosts with an AMD CPU.";
        }
        {
          name = "cpuIntel";
          layer = "hardware";
          description = "Enables Intel CPU microcode updates.";
          useWhen = "Use on hosts with an Intel CPU.";
        }
        {
          name = "graphicsAmd";
          layer = "hardware";
          description = "Enables AMDGPU, OpenGL, 32-bit graphics support, VA-API tooling, and Vulkan tooling.";
          useWhen = "Use on hosts whose primary GPU is AMD.";
        }
        {
          name = "graphicsIntel";
          layer = "hardware";
          description = "Enables Intel integrated or Arc graphics through the modesetting driver, OpenGL, 32-bit graphics support, VA-API tooling, Vulkan tooling, and Intel GPU diagnostics.";
          useWhen = "Use on hosts whose primary GPU is Intel integrated graphics or Intel Arc.";
        }
        {
          name = "graphicsNvidia";
          layer = "hardware";
          description = "Enables the NVIDIA driver, graphics support, NVIDIA settings, and Wayland-oriented NVIDIA session variables.";
          useWhen = "Use on hosts whose primary GPU is NVIDIA.";
        }
        {
          name = "tpmLuks";
          layer = "hardware";
          description = "Configures TPM2 support for unlocking a LUKS root device labeled `cryptroot`.";
          useWhen = "Use after the target host is intentionally installed with this disk layout.";
        }
      ];
    }
    {
      file = "system-software.md";
      title = "System Software Modules";
      intro = "System software modules configure operating system services, desktop sessions, display managers, and shared host behavior.";
      items = [
        {
          name = "base";
          layer = "systemSoftware";
          description = "Sets core Nix behavior, locale, keyboard layout, zsh support, baseline command-line tools, and the system state version.";
          useWhen = "Use on nearly every host.";
        }
        {
          name = "networking";
          layer = "systemSoftware";
          description = "Convenience import for NetworkManager, firewall, local service discovery, and time sync.";
          includes = [ "networkmanager" "firewall" "avahi" "timeSync" ];
          useWhen = "Use for normal desktop or laptop networking.";
        }
        {
          name = "networkmanager";
          layer = "systemSoftware";
          description = "Enables NetworkManager.";
          useWhen = "Use when the host should manage network connections through NetworkManager.";
        }
        {
          name = "firewall";
          layer = "systemSoftware";
          description = "Enables nftables and firewalld.";
          useWhen = "Use for a managed host firewall.";
        }
        {
          name = "avahi";
          layer = "systemSoftware";
          description = "Enables local network service discovery and mDNS name resolution.";
          useWhen = "Use when the host should find printers, shares, and local devices on trusted networks.";
        }
        {
          name = "timeSync";
          layer = "systemSoftware";
          description = "Enables Chrony time synchronization.";
          useWhen = "Use for normal network time sync.";
        }
        {
          name = "audioPipewire";
          layer = "systemSoftware";
          description = "Enables PipeWire audio with PulseAudio compatibility, ALSA support, 32-bit ALSA support, and realtime scheduling support.";
          useWhen = "Use for modern desktop audio.";
        }
        {
          name = "desktopServices";
          layer = "systemSoftware";
          description = "Convenience import for desktop support services such as Bluetooth, dconf, firmware updates, network shares, power profiles, printing, and removable storage.";
          includes = [ "bluetooth" "dconf" "firmwareUpdates" "networkShares" "powerManagement" "printing" "storageDesktop" ];
          useWhen = "Use on general-purpose desktop or laptop hosts.";
        }
        {
          name = "bluetooth";
          layer = "systemSoftware";
          description = "Enables Bluetooth hardware support.";
          useWhen = "Use on hosts that need Bluetooth devices.";
        }
        {
          name = "dconf";
          layer = "systemSoftware";
          description = "Enables dconf, which GNOME and several GTK applications use for settings.";
          useWhen = "Use with GNOME, GTK-heavy desktops, or Home Manager dconf settings.";
        }
        {
          name = "firmwareUpdates";
          layer = "systemSoftware";
          description = "Enables fwupd for firmware updates.";
          useWhen = "Use on hardware that receives firmware through LVFS/fwupd.";
        }
        {
          name = "networkShares";
          layer = "systemSoftware";
          description = "Installs SMB/NFS client tools and enables desktop virtual filesystem support for browsing network shares.";
          useWhen = "Use on graphical hosts that should browse or mount common network file shares.";
        }
        {
          name = "powerManagement";
          layer = "systemSoftware";
          description = "Enables desktop power services and defaults the host to the performance power profile.";
          useWhen = "Use on desktops and laptops where predictable performance is preferred.";
        }
        {
          name = "printing";
          layer = "systemSoftware";
          description = "Enables printing support.";
          useWhen = "Use when the host needs local or network printers.";
        }
        {
          name = "storageDesktop";
          layer = "systemSoftware";
          description = "Enables udisks2 for desktop removable-drive handling.";
          useWhen = "Use on graphical hosts where users mount USB drives or external disks.";
        }
        {
          name = "desktopKde";
          layer = "systemSoftware";
          description = "Enables the KDE Plasma 6 desktop and KDE portal support.";
          useWhen = "Use when you want KDE without the curated KDE app set.";
        }
        {
          name = "desktopKdeApps";
          layer = "systemSoftware";
          description = "Installs curated KDE applications and integration tools, including Dolphin, Kate, Okular, Spectacle, Discover, KDE Connect, and related utilities.";
          useWhen = "Use with KDE when you want a complete desktop app set.";
        }
        {
          name = "desktopKdeFull";
          layer = "systemSoftware";
          description = "Convenience import for KDE Plasma plus the curated KDE app set.";
          includes = [ "desktopKde" "desktopKdeApps" ];
          useWhen = "Use for a complete KDE system layer.";
        }
        {
          name = "desktopGnome";
          layer = "systemSoftware";
          description = "Enables GNOME and GNOME/GTK portal support.";
          useWhen = "Use when you want GNOME without the curated GNOME app set.";
        }
        {
          name = "desktopGnomeApps";
          layer = "systemSoftware";
          description = "Installs curated GNOME applications and utilities, including Files, Text Editor, Calendar, Calculator, Tweaks, System Monitor, and related tools.";
          useWhen = "Use with GNOME when you want a complete desktop app set.";
        }
        {
          name = "desktopGnomeFull";
          layer = "systemSoftware";
          description = "Convenience import for GNOME plus the curated GNOME app set.";
          includes = [ "desktopGnome" "desktopGnomeApps" ];
          useWhen = "Use for a complete GNOME system layer.";
        }
        {
          name = "desktopHyprland";
          layer = "systemSoftware";
          description = "Enables Hyprland, UWSM integration, XWayland, and Hyprland/GTK portal support.";
          useWhen = "Use for a Hyprland-capable system layer.";
        }
        {
          name = "displaySddm";
          layer = "systemSoftware";
          description = "Enables SDDM on Wayland with the Breeze theme and the shared wallpaper.";
          useWhen = "Use with KDE or Hyprland when SDDM should be the login manager.";
        }
        {
          name = "displayGdm";
          layer = "systemSoftware";
          description = "Enables GDM on Wayland and applies the shared dark wallpaper to the greeter.";
          useWhen = "Use with GNOME or any host that should use GDM as the login manager.";
        }
        {
          name = "flatpak";
          layer = "systemSoftware";
          description = "Enables Flatpak and adds Flathub as a system remote.";
          useWhen = "Use when users should be able to install Flatpak apps.";
        }
        {
          name = "fonts";
          layer = "systemSoftware";
          description = "Installs a practical base font set: Noto, CJK Noto, emoji, Liberation, and DejaVu.";
          useWhen = "Use on graphical hosts or any host that renders user-facing text.";
        }
        {
          name = "wallpaper";
          layer = "systemSoftware";
          description = "Installs the shared wallpaper into `/etc/wallpapers` for display managers and user sessions.";
          useWhen = "Use when display manager and desktop wallpaper should share this repo's visual defaults.";
        }
      ];
    }
    {
      file = "user-software.md";
      title = "User Software Modules";
      intro = "User software modules are the curated app menu for host repos. Some entries are simple installs, while others apply NixOS-specific defaults.";
      items = [
        {
          name = "chromium";
          layer = "userSoftware";
          description = "Enables Chromium through the NixOS program module.";
          useWhen = "Use when the host should provide Chromium. Pair with `homeSoftware.defaultApps` to make it the default browser.";
        }
        {
          name = "firefox";
          layer = "userSoftware";
          description = "Enables Firefox through the NixOS program module.";
          useWhen = "Use when the host should provide Firefox. Pair with `homeSoftware.defaultApps` to make it the default browser.";
        }
        {
          name = "onepassword";
          layer = "userSoftware";
          description = "Enables the 1Password CLI and GUI.";
          useWhen = "Use with the `onepassword` metamodule when the SSH agent should also be wired into Home Manager.";
        }
        {
          name = "steam";
          layer = "userSoftware";
          description = "Enables Steam and the Gamescope session.";
          useWhen = "Use when Steam should be available on the host.";
        }
      ];
    }
    {
      file = "home-software.md";
      title = "Home Software Modules";
      intro = "Home software modules are Home Manager building blocks. They configure a specific user's shell, applications, and desktop preferences.";
      items = [
        {
          name = "base";
          layer = "homeSoftware";
          description = "Enables Home Manager for the user.";
          useWhen = "Use in nearly every Home Manager user list.";
        }
        {
          name = "defaultApps";
          layer = "homeSoftware";
          description = "Adds `dendritic.defaultApps` options for browser, terminal, and file manager defaults.";
          useWhen = "Use when a host wants to set app defaults manually instead of taking a desktop metamodule's defaults.";
        }
        {
          name = "defaultAppsKde";
          layer = "homeSoftware";
          description = "Sets KDE-oriented defaults: Chromium for browser, Konsole for terminal, and Dolphin for file manager.";
          includes = [ "defaultApps" ];
          useWhen = "Usually consumed through the `kde` metamodule.";
        }
        {
          name = "defaultAppsGnome";
          layer = "homeSoftware";
          description = "Sets GNOME-oriented defaults: Firefox for browser, GNOME Console for terminal, and Nautilus for file manager.";
          includes = [ "defaultApps" ];
          useWhen = "Usually consumed through the `gnome` metamodule.";
        }
        {
          name = "defaultAppsHyprland";
          layer = "homeSoftware";
          description = "Sets Hyprland-oriented defaults: Chromium for browser, Kitty for terminal, and Dolphin for file manager.";
          includes = [ "defaultApps" ];
          useWhen = "Usually consumed through the `hyprland` metamodule.";
        }
        {
          name = "ssh";
          layer = "homeSoftware";
          description = "Enables Home Manager SSH configuration with default config generation disabled.";
          useWhen = "Use when the user's SSH config should be managed explicitly.";
        }
        {
          name = "sshOnepasswordAgent";
          layer = "homeSoftware";
          description = "Imports the SSH base module and points SSH at the 1Password agent socket.";
          includes = [ "ssh" ];
          useWhen = "Use when 1Password should provide SSH keys.";
        }
        {
          name = "terminalKitty";
          layer = "homeSoftware";
          description = "Configures Kitty with the shared dark theme, font choices, padding, and quiet close behavior.";
          useWhen = "Use when Kitty is the preferred terminal.";
        }
        {
          name = "gtkQtBreezeDark";
          layer = "homeSoftware";
          description = "Applies the shared dark Breeze look to GTK and Qt apps and installs Breeze theme assets.";
          useWhen = "Use through the `kde` or `hyprland` metamodule unless you intentionally need this theme by itself.";
        }
        {
          name = "plasmaBreezeDark";
          layer = "homeSoftware";
          description = "Applies Plasma look-and-feel, icons, cursor, fonts, wallpaper, and KWin hot-corner defaults through plasma-manager.";
          useWhen = "Use through the `kde` metamodule unless you are composing Plasma settings by hand.";
        }
        {
          name = "gnomeBreezeDark";
          layer = "homeSoftware";
          description = "Applies the shared wallpaper, dark color preference, cursor, and fonts through GNOME dconf settings.";
          useWhen = "Use through the `gnome` metamodule unless you are composing GNOME settings by hand.";
        }
        {
          name = "hyprlandSession";
          layer = "homeSoftware";
          description = "Configures the Hyprland session, environment, launcher bindings, screenshots, lock command, workspace keys, and a built-in shortcut reference terminal.";
          useWhen = "Use when assembling a custom Hyprland home setup.";
        }
        {
          name = "hyprlandLauncher";
          layer = "homeSoftware";
          description = "Configures fuzzel as the application launcher with the shared dark theme.";
          useWhen = "Use when assembling a custom Hyprland home setup.";
        }
        {
          name = "hyprlandBar";
          layer = "homeSoftware";
          description = "Configures Waybar with workspace, window, clock, audio, network, battery, and tray modules.";
          useWhen = "Use when assembling a custom Hyprland home setup.";
        }
        {
          name = "hyprlandWallpaper";
          layer = "homeSoftware";
          description = "Configures hyprpaper to use the shared wallpaper.";
          useWhen = "Use when assembling a custom Hyprland home setup.";
        }
        {
          name = "hyprlandNotifications";
          layer = "homeSoftware";
          description = "Configures mako notifications with the shared dark theme.";
          useWhen = "Use when assembling a custom Hyprland home setup.";
        }
        {
          name = "hyprlandFull";
          layer = "homeSoftware";
          description = "Convenience import for the complete Hyprland Home Manager setup.";
          includes = [ "hyprlandSession" "hyprlandLauncher" "hyprlandBar" "hyprlandWallpaper" "hyprlandNotifications" ];
          useWhen = "Use through the `hyprland` metamodule unless you are composing Hyprland home settings by hand.";
        }
      ];
    }
    {
      file = "meta-modules.md";
      title = "Metamodules";
      intro = "Metamodules are cross-menu bundles. They are for cohesive features that would otherwise require remembering several entries across system, user, and home menus.";
      items = [
        {
          name = "kde";
          layer = "metaModules";
          description = "KDE desktop bundle spanning the system session and Home Manager theming.";
          systemSoftware = [ "desktopKdeFull" "fonts" ];
          userSoftware = [ "chromium" ];
          homeSoftware = [ "defaultAppsKde" "gtkQtBreezeDark" "plasmaBreezeDark" ];
          useWhen = "Use when a host should provide KDE Plasma with the repo's shared fonts, dark Breeze defaults, and KDE-oriented app defaults. Add one display manager, usually `displaySddm`, in `systemSoftware`.";
        }
        {
          name = "gnome";
          layer = "metaModules";
          description = "GNOME desktop bundle spanning the system session and Home Manager theming.";
          systemSoftware = [ "desktopGnomeFull" "fonts" ];
          userSoftware = [ "firefox" ];
          homeSoftware = [ "defaultAppsGnome" "gnomeBreezeDark" ];
          useWhen = "Use when a host should provide GNOME with the repo's shared fonts, dark wallpaper, interface defaults, and GNOME-oriented app defaults. Add one display manager, usually `displayGdm`, in `systemSoftware`.";
        }
        {
          name = "hyprland";
          layer = "metaModules";
          description = "Hyprland bundle spanning system session support, GTK/Qt Breeze theming, and the complete Hyprland Home Manager setup.";
          systemSoftware = [ "desktopHyprland" "fonts" ];
          userSoftware = [ "chromium" ];
          homeSoftware = [ "defaultAppsHyprland" "gtkQtBreezeDark" "hyprlandFull" "terminalKitty" ];
          useWhen = "Use when a host should provide the repo's full Hyprland experience with shared fonts and Hyprland-oriented app defaults. Add one display manager, usually `displaySddm`, in `systemSoftware`.";
        }
        {
          name = "onepassword";
          layer = "metaModules";
          description = "1Password bundle spanning system-installed 1Password support and the Home Manager SSH agent integration.";
          userSoftware = [ "onepassword" ];
          homeSoftware = [ "sshOnepasswordAgent" ];
          useWhen = "Use when the user wants both the 1Password app/CLI and SSH keys served by the 1Password agent.";
        }
      ];
    }
  ];
}
