{ pkgs, ... }:
{
  imports = [
    ../../modules/system/base.nix
    ../../modules/system/networking.nix
    ../../modules/system/audio-pipewire.nix
    ../../modules/system/compatibility.nix
    ../../modules/system/desktop-services.nix
    ../../modules/system/flatpak.nix
    ../../modules/system/maintenance.nix
    ../../modules/system/nix-ux.nix
    ../../modules/system/unfree.nix
    ../../modules/system/wallpaper.nix
  ];

  programs.zsh.enable = true;

  environment.systemPackages = [ pkgs.brave-origin ];

  # Prefer native Wayland for Chromium/Electron applications regardless of the
  # selected display manager.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
