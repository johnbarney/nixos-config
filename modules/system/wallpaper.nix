{ ... }:
let
  theme = import ../../lib/theme.nix;
in
{
  environment.etc."wallpapers/dark_jungle.jpeg".source = theme.wallpaper.source;
}
