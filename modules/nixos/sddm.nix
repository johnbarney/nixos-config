{ ... }:
{
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.theme = "breeze";
  services.displayManager.sddm.settings = {
    Theme = {
      Current = "breeze";
      Background = "/etc/wallpapers/dark_jungle.jpeg";
    };
  };

  # Improve Wayland behavior for Electron/Chromium apps
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
