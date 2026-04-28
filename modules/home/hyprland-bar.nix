{ ... }:
let
  theme = import ../../lib/theme.nix;
in
{
  programs.waybar = {
    enable = true;
    settings = [
      {
        layer = "top";
        position = "top";
        height = 34;
        "modules-left" = [ "hyprland/workspaces" "hyprland/window" ];
        "modules-center" = [ "clock" ];
        "modules-right" = [ "pulseaudio" "network" "battery" "tray" ];
        "hyprland/workspaces" = {
          "disable-scroll" = true;
          "all-outputs" = true;
        };
        clock = {
          format = "{:%a %b %-d  %-I:%M %p}";
          "tooltip-format" = "{:%Y-%m-%d %H:%M:%S}";
        };
        pulseaudio = {
          format = "{volume}% {icon}";
          "format-muted" = "muted";
          "format-icons".default = [ "vol" "vol" "vol" ];
        };
        network = {
          "format-wifi" = "{essid}";
          "format-ethernet" = "wired";
          "format-disconnected" = "offline";
          "tooltip-format" = "{ipaddr}";
        };
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}%";
          "format-charging" = "+{capacity}%";
        };
      }
    ];
    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "${theme.fonts.sans}";
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(35, 38, 41, 0.92);
        color: ${theme.colors.foreground};
        border-bottom: 1px solid rgba(61, 174, 233, 0.35);
      }

      #workspaces,
      #window,
      #clock,
      #pulseaudio,
      #network,
      #battery,
      #tray {
        margin: 6px 8px;
        padding: 0 10px;
        border-radius: 10px;
        background: rgba(49, 54, 59, 0.92);
      }

      #workspaces button {
        color: #bdc3c7;
        padding: 0 6px;
        border-radius: 8px;
      }

      #workspaces button.active {
        color: ${theme.colors.foreground};
        background: ${theme.colors.accent};
      }

      #window {
        color: #fcfcfc;
      }

      #tray {
        padding-right: 14px;
      }
    '';
  };
}
