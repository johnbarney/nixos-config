{ ... }:
{
  imports = [
    ../../modules/system/base.nix
    ../../modules/system/networking.nix
    ../../modules/system/audio-pipewire.nix
    ../../modules/system/desktop-services.nix
    ../../modules/system/flatpak.nix
    ../../modules/system/wallpaper.nix
  ];
}
