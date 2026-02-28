{ pkgs, plasma-manager, ... }:
{
  home.username = "johnbarney";
  home.homeDirectory = "/home/johnbarney";

  imports = [
    plasma-manager.homeModules.plasma-manager
  ];

  programs.home-manager.enable = true;
  programs.zsh = {
    enable = true;
    initContent = ''
      codex() {
        local codex_bin
        codex_bin="$(whence -p codex 2>/dev/null || true)"
        if [ -n "$codex_bin" ]; then
          "$codex_bin" "$@"
        else
          npx -y @openai/codex "$@"
        fi
      }
    '';
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      identityAgent = "~/.1password/agent.sock";
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
    nodejs_22
  ];

  home.stateVersion = "25.11";
}
