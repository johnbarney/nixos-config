{ ... }:
let
  theme = import ../../lib/theme.nix;
in
{
  programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel = theme.kde.lookAndFeel;
      iconTheme = theme.kde.iconTheme;
      cursor = {
        theme = theme.cursor.name;
        size = theme.cursor.size;
      };
      wallpaper = theme.wallpaper.path;
    };
    fonts = {
      general = {
        family = theme.fonts.sans;
        pointSize = 10;
      };
      fixedWidth = {
        family = theme.fonts.mono;
        pointSize = 10;
      };
      windowTitle = {
        family = theme.fonts.sans;
        pointSize = 10;
      };
    };
    configFile = {
      # Disable Plasma/KWin hot corners.
      "kwinrc"."ElectricBorders" = {
        TopLeft = "None";
        TopRight = "None";
        BottomLeft = "None";
        BottomRight = "None";
      };
    };
  };
}
