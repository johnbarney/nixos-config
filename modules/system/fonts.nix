{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans-static
    noto-fonts-color-emoji
    liberation_ttf
    dejavu_fonts
  ];
}
