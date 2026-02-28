{ pkgs, plasma-manager, ... }:
{
  home.username = "johnbarney";
  home.homeDirectory = "/home/johnbarney";

  imports = [
    plasma-manager.homeManagerModules.plasma-manager
  ];

  programs.home-manager.enable = true;
  programs.zsh = {
    enable = true;
    shellAliases = {
      nix-update = "sudo nixos-rebuild switch --flake /etc/nixos#taipei-linux";
      codex = "npx -y @openai/codex";
    };
  };

  programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel = "org.kde.breeze.desktop";
      iconTheme = "breeze";
      cursor = {
        theme = "breeze_cursors";
        size = 24;
      };
      wallpaper = "/etc/fedora/wallpaper.png";
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
        bold = true;
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

  home.packages = with pkgs; [
    # User-specific packages can be added here.
    nodejs_22
  ];

  home.stateVersion = "25.11";
}
