{ config, lib, pkgs, ... }:
let
  cfg = config.dendritic.defaultApps;

  browserDesktopFiles = {
    chromium = "chromium-browser.desktop";
    firefox = "firefox.desktop";
  };

  terminalCommands = {
    gnomeConsole = "${pkgs.gnome-console}/bin/kgx";
    kitty = "${pkgs.kitty}/bin/kitty";
    konsole = "${pkgs.kdePackages.konsole}/bin/konsole";
  };

  fileManagerCommands = {
    dolphin = "${pkgs.kdePackages.dolphin}/bin/dolphin";
    nautilus = "${pkgs.nautilus}/bin/nautilus";
  };

  browserMimeTypes = [
    "text/html"
    "x-scheme-handler/about"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
  ];
in
{
  options.dendritic.defaultApps = {
    browser = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [
        "chromium"
        "firefox"
      ]);
      default = null;
      description = "Default browser for XDG MIME and URL handling.";
    };

    terminal = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [
        "gnomeConsole"
        "kitty"
        "konsole"
      ]);
      default = null;
      description = "Preferred terminal for Dendritic-managed shortcuts.";
    };

    fileManager = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [
        "dolphin"
        "nautilus"
      ]);
      default = null;
      description = "Preferred file manager for Dendritic-managed shortcuts.";
    };

    terminalCommand = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      readOnly = true;
      default = if cfg.terminal == null then null else terminalCommands.${cfg.terminal};
      description = "Resolved terminal command for Dendritic-managed modules.";
    };

    fileManagerCommand = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      readOnly = true;
      default = if cfg.fileManager == null then null else fileManagerCommands.${cfg.fileManager};
      description = "Resolved file manager command for Dendritic-managed modules.";
    };
  };

  config = lib.mkIf (cfg.browser != null) {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = lib.genAttrs browserMimeTypes (_: browserDesktopFiles.${cfg.browser});
    };
  };
}
