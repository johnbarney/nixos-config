{ pkgs, ... }:
let
  theme = import ../../lib/omarchy-theme.nix;
in
{
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    cursorTheme = {
      inherit (theme.cursor) name size;
      package = pkgs.adwaita-icon-theme;
    };
    font = {
      name = theme.fonts.sans;
      size = 10;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.theme = null;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };

  home.packages = with pkgs; [
    adwaita-icon-theme
    adw-gtk3
  ];
}
