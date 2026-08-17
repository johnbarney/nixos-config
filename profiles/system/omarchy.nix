# Omarchy-inspired Hyprland system profile.
{ pkgs, ... }:
{
  imports = [
    ../../modules/system/desktop-hyprland.nix
    ../../modules/system/fonts.nix
  ];

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
  security.pam.services.hyprlock = { };
}
