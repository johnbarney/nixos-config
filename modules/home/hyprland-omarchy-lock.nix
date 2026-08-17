{ pkgs, ... }:
let
  theme = import ../../lib/omarchy-theme.nix;
  lock = "${pkgs.hyprlock}/bin/hyprlock";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 2;
          blur_size = 6;
        }
      ];

      input-field = [
        {
          monitor = "";
          size = "300, 48";
          position = "0, -80";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(cdd6f4)";
          inner_color = "rgb(1e1e2e)";
          outer_color = "rgb(89b4fa)";
          outline_thickness = 2;
          placeholder_text = ''<span foreground="##${builtins.substring 1 6 theme.colors.muted}">Password</span>'';
        }
      ];
    };
  };

  services.hypridle = {
    enable = true;
    systemdTarget = "graphical-session.target";
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || ${lock}";
        before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
        after_sleep_cmd = "${hyprctl} dispatch dpms on";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = lock;
        }
        {
          timeout = 600;
          on-timeout = "${hyprctl} dispatch dpms off";
          on-resume = "${hyprctl} dispatch dpms on";
        }
      ];
    };
  };
}
