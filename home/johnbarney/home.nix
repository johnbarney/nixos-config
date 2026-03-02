{ pkgs, plasma-manager, ... }:
{
  home.username = "johnbarney";
  home.homeDirectory = "/home/johnbarney";

  imports = [
    plasma-manager.homeModules.plasma-manager
  ];

  programs.home-manager.enable = true;
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      brettm12345.nixfmt-vscode
      esbenp.prettier-vscode
      oderwat.indent-rainbow
      ms-vscode."makefile-tools"
      ms-python.python
      golang.go
    ];
  };
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

  home.packages = with pkgs; [
    nodejs_22
  ];

  home.stateVersion = "25.11";

  home.activation.installVscodeExtensions =
    let
      codeBin = "${pkgs.vscode}/bin/code";
    in
    # Codex is published as openai.chatgpt in VS Code Marketplace.
    ''
      if [ -x "${codeBin}" ]; then
        "${codeBin}" --install-extension ms-vscode.makefile-tools --force >/dev/null 2>&1 || true
        "${codeBin}" --install-extension openai.chatgpt --force >/dev/null 2>&1 || true
      fi
    '';
}
