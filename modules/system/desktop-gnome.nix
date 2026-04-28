{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gnome
    pkgs.xdg-desktop-portal-gtk
  ];
}
