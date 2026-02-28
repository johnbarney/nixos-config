{ pkgs, ... }:
{
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "plasmawayland";
  services.desktopManager.plasma6.enable = true;

  programs.kdeconnect.enable = true;

  programs.chromium.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-kde ];

  environment.systemPackages = with pkgs; [
    kdePackages.ark
    kdePackages.discover
    kdePackages.dolphin
    kdePackages.dolphin-plugins
    kdePackages.bluedevil
    kdePackages.dragon
    kdePackages.elisa
    kdePackages.kate
    kdePackages.kcalc
    kdePackages.kcharselect
    kdePackages.kclock
    kdePackages.kde-gtk-config
    kdePackages.kdeplasma-addons
    kdePackages.konsole
    kdePackages.kolourpaint
    kdePackages.kontrast
    kdePackages.kwalletmanager
    kdePackages.kdegraphics-thumbnailers
    kdePackages.kio-extras
    kdePackages.kio-admin
    kdePackages.kio-fuse
    kdePackages.kscreen
    kdePackages.okular
    kdePackages.plasma-systemmonitor
    kdePackages.plasma-browser-integration
    kdePackages.print-manager
    kdePackages.spectacle
    kdePackages.xdg-desktop-portal-kde
    kdePackages.gwenview
    kdePackages.partitionmanager
    kdePackages.filelight
    kdePackages.kamoso
    kdePackages.khelpcenter
    kdePackages.sddm-kcm
  ];
}
