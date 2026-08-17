{ ... }:
let
  theme = import ../../lib/omarchy-theme.nix;
in
{
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      font_family = theme.fonts.mono;
      font_size = 10;
      background = theme.colors.background;
      foreground = theme.colors.foreground;
      selection_background = theme.colors.accent;
      selection_foreground = theme.colors.darkerBackground;
      cursor = theme.colors.accent;
      cursor_text_color = theme.colors.darkerBackground;
      active_border_color = theme.colors.accent;
      inactive_border_color = theme.colors.muted;
      window_padding_width = 10;
    };
  };
}
