{ config, pkgs, plasma-manager, ... }:
let
  brewPrefix = "${config.home.homeDirectory}/.linuxbrew";
in
{
  home.username = "johnbarney";
  home.homeDirectory = "/home/johnbarney";

  imports = [
    plasma-manager.homeModules.plasma-manager
  ];

  programs.home-manager.enable = true;
  programs.zsh = {
    enable = true;
    shellAliases = {
      nix-update = "sudo nixos-rebuild switch --flake /etc/nixos#taipei-linux";
      install-codex = "install-homebrew-codex";
    };
    initContent = ''
      if [ -x "${brewPrefix}/bin/brew" ]; then
        eval "$(${brewPrefix}/bin/brew shellenv)"
      fi
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
    # Installs Homebrew + codex on demand; run: install-codex
    (writeShellScriptBin "install-homebrew-codex" ''
      set -euo pipefail

      if ! command -v brew >/dev/null 2>&1 && [ ! -x "${brewPrefix}/bin/brew" ]; then
        echo "Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(${curl}/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi

      if [ -x "${brewPrefix}/bin/brew" ]; then
        eval "$(${brewPrefix}/bin/brew shellenv)"
      fi

      if ! command -v brew >/dev/null 2>&1; then
        echo "brew not found after installation." >&2
        exit 1
      fi

      if ! brew list --formula codex >/dev/null 2>&1; then
        echo "Installing codex via Homebrew..."
        brew install codex
      else
        echo "codex is already installed."
      fi
    '')
  ];

  home.sessionPath = [
    "${brewPrefix}/bin"
    "${brewPrefix}/sbin"
  ];

  home.stateVersion = "25.11";
}
