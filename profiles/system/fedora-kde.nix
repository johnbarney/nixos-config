# Fedora-inspired KDE Plasma system profile.
{ ... }:
{
  imports = [
    ../../modules/system/desktop-kde.nix
    ../../modules/system/desktop-kde-apps.nix
    ../../modules/system/fonts.nix
  ];
}
