{ ... }:
let
  theme = import ../../lib/theme.nix;
in
{
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;

  programs.dconf.profiles.gdm.databases = [
    {
      settings = {
        "org/gnome/desktop/background" = {
          picture-uri = theme.wallpaper.uri;
          picture-uri-dark = theme.wallpaper.uri;
          picture-options = "zoom";
          primary-color = theme.colors.background;
          secondary-color = theme.colors.background;
        };
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
        "org/gnome/desktop/screensaver" = {
          picture-uri = theme.wallpaper.uri;
          primary-color = theme.colors.background;
          secondary-color = theme.colors.background;
        };
      };
    }
  ];
}
