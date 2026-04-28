{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      macos_option_as_alt = true;
      font_family = "Noto Sans Mono";
      font_size = 10;
      background = "#232629";
      foreground = "#eff0f1";
      selection_background = "#3daee9";
      selection_foreground = "#eff0f1";
      cursor = "#3daee9";
      cursor_text_color = "#232629";
      active_border_color = "#3daee9";
      inactive_border_color = "#4b4f54";
      window_padding_width = 10;
    };
  };
}
