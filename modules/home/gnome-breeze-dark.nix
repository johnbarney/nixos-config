{ ... }:
let
  theme = import ../../lib/theme.nix;
in
{
  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri = theme.wallpaper.uri;
      picture-uri-dark = theme.wallpaper.uri;
      picture-options = "zoom";
      primary-color = theme.colors.background;
      secondary-color = theme.colors.background;
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      cursor-theme = theme.cursor.name;
      font-name = "${theme.fonts.sans} 10";
      monospace-font-name = "${theme.fonts.mono} 10";
    };

    "org/gnome/desktop/screensaver" = {
      picture-uri = theme.wallpaper.uri;
      primary-color = theme.colors.background;
      secondary-color = theme.colors.background;
    };
  };
}
