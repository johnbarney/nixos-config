{ config, lib, pkgs, ... }:
let
  theme = import ../../lib/theme.nix;
  defaultApps = config.dendritic.defaultApps;
  screenshotDir = "${config.home.homeDirectory}/Pictures/Screenshots";
  terminalBin =
    if defaultApps.terminalCommand == null then
      "${pkgs.kitty}/bin/kitty"
    else
      defaultApps.terminalCommand;
  fileManagerBin = defaultApps.fileManagerCommand;
  hyprCheatsheetCommand =
    "${terminalBin} --class hypr-cheatsheet --title 'Hypr Cheatsheet' --override remember_window_size=no --override initial_window_width=52c --override initial_window_height=22c ${hyprCheatsheet}/bin/hypr-cheatsheet";
  hyprCheatsheet = pkgs.writeShellScriptBin "hypr-cheatsheet" ''
    cat <<'EOF'
    Hyprland shortcuts

    SUPER+Space      Launcher
    SUPER+Return     Terminal
    SUPER+B          Browser
    SUPER+E          Files
    SUPER+Q          Close window
    SUPER+F          Fullscreen

    SUPER+Tab        Next window
    SUPER+Shift+Tab  Previous window

    SUPER+H/J/K/L          Move focus
    SUPER+Shift+H/J/K/L    Move window
    SUPER+Ctrl+H/J/K/L     Resize window

    SUPER+1..0       Switch workspace
    SUPER+Shift+1..0 Send window to workspace

    SUPER+Shift+3    Screenshot screen
    SUPER+Shift+4    Screenshot area
    SUPER+Ctrl+L     Lock session

    Close this window anytime.
    Reopen with SUPER+/
    EOF

    exec tail -f /dev/null
  '';
  screenshotFull = pkgs.writeShellScriptBin "capture-screen" ''
    set -eu
    mkdir -p "${screenshotDir}"
    target="${screenshotDir}/$(date +%Y-%m-%d-%H%M%S).png"
    ${pkgs.grim}/bin/grim "$target"
  '';
  screenshotArea = pkgs.writeShellScriptBin "capture-area" ''
    set -eu
    mkdir -p "${screenshotDir}"
    target="${screenshotDir}/$(date +%Y-%m-%d-%H%M%S).png"
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "$target"
  '';
  hyprWorkspaces = lib.concatLists (
    builtins.genList
      (i:
        let
          workspace = toString (i + 1);
          key = if i == 9 then "0" else workspace;
        in
        [
          "$mainMod, ${key}, workspace, ${workspace}"
          "$mainMod SHIFT, ${key}, movetoworkspace, ${workspace}"
        ])
      10
  );
in
{
  imports = [
    ./default-apps.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;
    settings = {
      "$mainMod" = "SUPER";

      monitor = ",preferred,auto,1";

      "exec-once" = [
        "${pkgs.waybar}/bin/waybar"
        hyprCheatsheetCommand
      ];

      env = [
        "XCURSOR_SIZE,${toString theme.cursor.size}"
        "XCURSOR_THEME,${theme.cursor.name}"
        "GTK_THEME,${theme.kde.gtkTheme}"
        "ICON_THEME,breeze-dark"
        "QT_STYLE_OVERRIDE,${theme.kde.qtStyle}"
        "QT_QPA_PLATFORM,wayland;xcb"
      ];

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
          "tap-to-click" = true;
          drag_lock = true;
          clickfinger_behavior = true;
        };
      };

      general = {
        gaps_in = 6;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(3daee9ff)";
        "col.inactive_border" = "rgba(585b70aa)";
        resize_on_border = true;
        layout = "dwindle";
      };

      decoration = {
        rounding = 12;
        blur = {
          enabled = true;
          size = 6;
          passes = 2;
        };
      };

      animations = {
        enabled = true;
      };

      dwindle = {
        preserve_split = true;
      };

      gestures = {
        workspace_swipe = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      windowrulev2 = [
        "float,class:^(hypr-cheatsheet)$"
        "pin,class:^(hypr-cheatsheet)$"
        "stayfocused,class:^(hypr-cheatsheet)$"
        "size 420 360,class:^(hypr-cheatsheet)$"
        "move 20 56,class:^(hypr-cheatsheet)$"
        "opacity 0.92 0.92,class:^(hypr-cheatsheet)$"
        "noborder,class:^(hypr-cheatsheet)$"
      ];

      bind =
        [
          "$mainMod, RETURN, exec, ${terminalBin}"
          "$mainMod, SPACE, exec, ${pkgs.fuzzel}/bin/fuzzel"
          "$mainMod, B, exec, ${pkgs.xdg-utils}/bin/xdg-open https://example.com"
          "$mainMod, slash, exec, ${hyprCheatsheetCommand}"
          "$mainMod, TAB, cyclenext"
          "$mainMod SHIFT, TAB, cyclenext, prev"
          "$mainMod, Q, killactive"
          "$mainMod SHIFT, F, togglefloating"
          "$mainMod, F, fullscreen, 0"
          "$mainMod, V, togglefloating"
          "$mainMod, H, movefocus, l"
          "$mainMod, J, movefocus, d"
          "$mainMod, K, movefocus, u"
          "$mainMod, L, movefocus, r"
          "$mainMod SHIFT, H, movewindow, l"
          "$mainMod SHIFT, J, movewindow, d"
          "$mainMod SHIFT, K, movewindow, u"
          "$mainMod SHIFT, L, movewindow, r"
          "$mainMod CTRL, H, resizeactive, -80 0"
          "$mainMod CTRL, J, resizeactive, 0 80"
          "$mainMod CTRL, K, resizeactive, 0 -80"
          "$mainMod CTRL, L, resizeactive, 80 0"
          "$mainMod, P, pseudo"
          "$mainMod, S, togglesplit"
          "$mainMod SHIFT, 3, exec, ${screenshotFull}/bin/capture-screen"
          "$mainMod SHIFT, 4, exec, ${screenshotArea}/bin/capture-area"
          "$mainMod CTRL, L, exec, ${pkgs.systemd}/bin/loginctl lock-session"
        ]
        ++ lib.optionals (fileManagerBin != null) [
          "$mainMod, E, exec, ${fileManagerBin}"
        ]
        ++ hyprWorkspaces;

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 10%+"
        ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 10%-"
      ];

      bindl = [
        ", XF86AudioMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ", XF86AudioNext, exec, ${pkgs.playerctl}/bin/playerctl next"
        ", XF86AudioPrev, exec, ${pkgs.playerctl}/bin/playerctl previous"
      ];
    };
  };

  home.packages = with pkgs; [
    brightnessctl
    grim
    hyprCheatsheet
    nodejs_22
    playerctl
    screenshotArea
    screenshotFull
    slurp
    wl-clipboard
  ];
}
