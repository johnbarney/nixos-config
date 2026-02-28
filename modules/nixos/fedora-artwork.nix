{ lib, pkgs, ... }:
let
  fedoraWallpaper = pkgs.fetchurl {
    url = "https://commons.wikimedia.org/wiki/Special:FilePath/Fedora_43_default_wallpaper.png";
    hash = "sha1-nP1RzBE3YUCbGlJ9n32LzE+XdKo=";
  };
in
{
  environment.etc."fedora/wallpaper.png".source = fedoraWallpaper;
}
