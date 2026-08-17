# Fedora-inspired GNOME home profile.
{ ... }:
{
  imports = [
    ../../modules/home/default-apps-gnome.nix
    ../../modules/home/gnome-breeze-dark.nix
  ];
}
