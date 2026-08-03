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
}
