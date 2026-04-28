{ pkgs, ... }:
{
  programs.kdeconnect.enable = true;

  environment.systemPackages = with pkgs.kdePackages; [
    ark
    bluedevil
    discover
    dolphin
    dolphin-plugins
    dragon
    elisa
    filelight
    gwenview
    kamoso
    kate
    kcalc
    kcharselect
    kclock
    kde-gtk-config
    kdegraphics-thumbnailers
    kdeplasma-addons
    khelpcenter
    kio-admin
    kio-extras
    kio-fuse
    kolourpaint
    konsole
    kontrast
    kscreen
    kwalletmanager
    okular
    partitionmanager
    plasma-browser-integration
    plasma-systemmonitor
    print-manager
    sddm-kcm
    spectacle
    xdg-desktop-portal-kde
  ];
}
