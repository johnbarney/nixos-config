{ ... }:
let
  theme = import ../../lib/theme.nix;
in
{
  services.mako = {
    enable = true;
    settings = {
      "default-timeout" = 5000;
      "border-radius" = 10;
      padding = "12";
      margin = "16";
      "background-color" = "${theme.colors.background}f2";
      "text-color" = "${theme.colors.foreground}ff";
      "border-color" = "${theme.colors.accent}ff";
    };
  };
}
