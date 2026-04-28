{ pkgs, ... }:
let
  theme = import ../../lib/theme.nix;
  terminalBin = "${pkgs.kitty}/bin/kitty";
in
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = terminalBin;
        width = 48;
        "horizontal-pad" = 20;
        "vertical-pad" = 14;
        "inner-pad" = 12;
        "line-height" = 24;
      };
      colors = {
        background = "232629f2";
        text = "eff0f1ff";
        input = "eff0f1ff";
        prompt = "3daee9ff";
        selection = "3daee933";
        "selection-text" = "ffffffff";
        match = "3daee9ff";
        border = "3daee9ff";
      };
      border = {
        width = 2;
        radius = 10;
      };
    };
  };
}
