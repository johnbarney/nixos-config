{ ... }:
{
  imports = [ ../system/unfree.nix ];

  programs._1password.enable = true;
  programs._1password-gui.enable = true;
}
