{ ... }:
let
  theme = import ../../lib/theme.nix;
in
{
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.theme = "breeze";
  services.displayManager.sddm.settings = {
    Theme = {
      Current = "breeze";
      Background = theme.wallpaper.path;
    };
  };

  # Improve Wayland behavior for Electron/Chromium apps
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
