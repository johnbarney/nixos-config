{ ... }:
let
  theme = import ../../lib/theme.nix;
in
{
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ theme.wallpaper.path ];
      wallpaper = [ ",${theme.wallpaper.path}" ];
    };
  };
}
