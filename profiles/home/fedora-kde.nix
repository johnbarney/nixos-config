# Fedora-inspired KDE Plasma home profile.
{ ... }:
{
  imports = [
    ../../modules/home/default-apps-kde.nix
    ../../modules/home/gtk-qt-breeze-dark.nix
    ../../modules/home/plasma-breeze-dark.nix
  ];
}
