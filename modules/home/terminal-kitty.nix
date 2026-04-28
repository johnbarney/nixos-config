{ pkgs, ... }:
let
  theme = import ../../lib/theme.nix;
in
{
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      macos_option_as_alt = true;
      font_family = theme.fonts.mono;
      font_size = 10;
      background = theme.colors.background;
      foreground = theme.colors.foreground;
      selection_background = theme.colors.accent;
      selection_foreground = theme.colors.foreground;
      cursor = theme.colors.accent;
      cursor_text_color = theme.colors.background;
      active_border_color = theme.colors.accent;
      inactive_border_color = "#4b4f54";
      window_padding_width = 10;
    };
  };
}
