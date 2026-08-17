# Omarchy-inspired Hyprland home profile.
{ ... }:
{
  imports = [
    ../../modules/home/appearance-omarchy.nix
    ../../modules/home/default-apps-omarchy.nix
    ../../modules/home/hyprland-omarchy.nix
    ../../modules/home/hyprland-omarchy-lock.nix
    ../../modules/home/quickshell-omarchy.nix
    ../../modules/home/terminal-omarchy.nix
  ];
}
