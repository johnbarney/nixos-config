{ plasma-manager, ... }:
{
  imports = [
    plasma-manager.homeModules.plasma-manager
  ];

  programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      iconTheme = "breeze";
      cursor = {
        theme = "breeze_cursors";
        size = 24;
      };
      wallpaper = "/etc/wallpapers/dark_jungle.jpeg";
    };
    fonts = {
      general = {
        family = "Noto Sans";
        pointSize = 10;
      };
      fixedWidth = {
        family = "Noto Sans Mono";
        pointSize = 10;
      };
      windowTitle = {
        family = "Noto Sans";
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
