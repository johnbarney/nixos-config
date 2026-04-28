{ pkgs, ... }:
let
  theme = import ../../lib/theme.nix;
in
{
  gtk = {
    enable = true;
    theme = {
      name = theme.kde.gtkTheme;
      package = pkgs.kdePackages.breeze-gtk;
    };
    iconTheme = {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze-icons;
    };
    cursorTheme = {
      name = theme.cursor.name;
      package = pkgs.kdePackages.breeze;
      size = theme.cursor.size;
    };
    font = {
      name = theme.fonts.sans;
      size = 10;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.theme = null;
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = theme.kde.qtStyle;
  };

  home.packages = with pkgs; [
    kdePackages.breeze
    kdePackages.breeze-gtk
    kdePackages.breeze-icons
  ];
}
