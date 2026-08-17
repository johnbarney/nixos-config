{
  config,
  lib,
  pkgs,
  ...
}:
let
  desktopTheme = import ../../lib/theme.nix;
  theme = import ../../lib/omarchy-theme.nix;
  defaultApps = config.dendritic.defaultApps;
  lua = lib.generators.mkLuaInline;

  terminal =
    if defaultApps.terminalCommand == null then
      "${pkgs.kitty}/bin/kitty"
    else
      defaultApps.terminalCommand;
  fileManager = defaultApps.fileManagerCommand;
  browser = "${pkgs.gtk3}/bin/gtk-launch brave-origin.desktop";
  shell = "${lib.getExe pkgs.quickshell} --config omarchy ipc call omarchy";
  lock = "${pkgs.hyprlock}/bin/hyprlock";
  screenshotDir = "${config.home.homeDirectory}/Pictures/Screenshots";

  screenshotFull = pkgs.writeShellScriptBin "capture-screen" ''
    set -eu
    mkdir -p "${screenshotDir}"
    target="${screenshotDir}/$(date +%Y-%m-%d-%H%M%S).png"
    ${pkgs.grim}/bin/grim "$target"
    ${pkgs.libnotify}/bin/notify-send "Screenshot saved" "$target"
  '';
  screenshotArea = pkgs.writeShellScriptBin "capture-area" ''
    set -eu
    mkdir -p "${screenshotDir}"
    target="${screenshotDir}/$(date +%Y-%m-%d-%H%M%S).png"
    geometry="$(${pkgs.slurp}/bin/slurp)"
    ${pkgs.grim}/bin/grim -g "$geometry" "$target"
    ${pkgs.libnotify}/bin/notify-send "Screenshot saved" "$target"
  '';

  mkBindWith = options: key: dispatcher: {
    _args = [
      key
      (lua dispatcher)
      options
    ];
  };
  mkBind = mkBindWith { };
  mkExecWith = options: key: command:
    mkBindWith options key "hl.dsp.exec_cmd(${builtins.toJSON command})";
  mkExec = mkExecWith { };

  workspaceBindings = lib.concatLists (
    builtins.genList (
      i:
      let
        workspace = toString (i + 1);
        key = if i == 9 then "0" else workspace;
      in
      [
        (mkBind "SUPER + ${key}" ''hl.dsp.focus({ workspace = "${workspace}" })'')
        (mkBind "SUPER + SHIFT + ${key}" ''hl.dsp.window.move({ workspace = "${workspace}" })'')
      ]
    ) 10
  );
in
{
  imports = [
    ./default-apps.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    configType = "lua";
    systemd.enable = false;
    xwayland.enable = true;

    settings = {
      config = {
        monitor = ",preferred,auto,1";

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          repeat_rate = 40;
          repeat_delay = 250;
          numlock_by_default = true;
          touchpad = {
            natural_scroll = false;
            clickfinger_behavior = true;
            scroll_factor = 0.4;
          };
        };

        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          col = {
            active_border = {
              colors = [
                "rgba(89b4faee)"
                "rgba(94e2d5ee)"
              ];
              angle = 45;
            };
            inactive_border = "rgba(585b70aa)";
          };
          resize_on_border = false;
          allow_tearing = false;
          layout = "dwindle";
        };

        decoration = {
          rounding = 0;
          shadow.enabled = false;
          blur.enabled = false;
        };

        animations.enabled = true;

        dwindle = {
          preserve_split = true;
          force_split = 2;
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          disable_scale_notification = true;
          focus_on_activate = true;
        };

        cursor = {
          hide_on_key_press = true;
          warp_on_change_workspace = 1;
        };

        xwayland.force_zero_scaling = true;
      };

      env = [
        {
          _args = [
            "XCURSOR_SIZE"
            (toString theme.cursor.size)
          ];
        }
        {
          _args = [
            "XCURSOR_THEME"
            theme.cursor.name
          ];
        }
        {
          _args = [
            "GDK_BACKEND"
            "wayland,x11,*"
          ];
        }
        {
          _args = [
            "QT_QPA_PLATFORM"
            "wayland;xcb"
          ];
        }
        {
          _args = [
            "QT_QPA_PLATFORMTHEME"
            "gtk3"
          ];
        }
        {
          _args = [
            "MOZ_ENABLE_WAYLAND"
            "1"
          ];
        }
        {
          _args = [
            "ELECTRON_OZONE_PLATFORM_HINT"
            "wayland"
          ];
        }
        {
          _args = [
            "XDG_CURRENT_DESKTOP"
            "Hyprland"
          ];
        }
      ];

      bind = [
        (mkExec "SUPER + RETURN" terminal)
        (mkExec "SUPER + SHIFT + RETURN" browser)
        (mkExec "SUPER + SHIFT + B" browser)
        (mkExec "SUPER + SPACE" "${shell} toggleLauncher")
        (mkExec "SUPER + ALT + SPACE" "${shell} toggleLauncher")

        (mkBind "SUPER + W" "hl.dsp.window.close()")
        (mkBind "SUPER + J" ''hl.dsp.layout("togglesplit")'')
        (mkBind "SUPER + P" "hl.dsp.window.pseudo()")
        (mkBind "SUPER + T" ''hl.dsp.window.float({ action = "toggle" })'')
        (mkBind "SUPER + F" ''hl.dsp.window.fullscreen({ mode = "fullscreen" })'')

        (mkBind "SUPER + LEFT" ''hl.dsp.focus({ direction = "l" })'')
        (mkBind "SUPER + RIGHT" ''hl.dsp.focus({ direction = "r" })'')
        (mkBind "SUPER + UP" ''hl.dsp.focus({ direction = "u" })'')
        (mkBind "SUPER + DOWN" ''hl.dsp.focus({ direction = "d" })'')
        (mkBind "SUPER + SHIFT + LEFT" ''hl.dsp.window.swap({ direction = "l" })'')
        (mkBind "SUPER + SHIFT + RIGHT" ''hl.dsp.window.swap({ direction = "r" })'')
        (mkBind "SUPER + SHIFT + UP" ''hl.dsp.window.swap({ direction = "u" })'')
        (mkBind "SUPER + SHIFT + DOWN" ''hl.dsp.window.swap({ direction = "d" })'')
        (mkBind "ALT + TAB" "hl.dsp.window.cycle_next()")
        (mkBind "ALT + SHIFT + TAB" "hl.dsp.window.cycle_next({ next = false })")

        (mkExec "PRINT" "${screenshotArea}/bin/capture-area")
        (mkExec "SHIFT + PRINT" "${screenshotFull}/bin/capture-screen")
        (mkExec "SUPER + CTRL + L" lock)

        (mkExecWith {
          locked = true;
          repeating = true;
        } "XF86AudioRaiseVolume" "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")
        (mkExecWith {
          locked = true;
          repeating = true;
        } "XF86AudioLowerVolume" "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
        (mkExecWith {
          locked = true;
        } "XF86AudioMute" "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")
        (mkExecWith {
          locked = true;
          repeating = true;
        } "XF86MonBrightnessUp" "${pkgs.brightnessctl}/bin/brightnessctl set 5%+")
        (mkExecWith {
          locked = true;
          repeating = true;
        } "XF86MonBrightnessDown" "${pkgs.brightnessctl}/bin/brightnessctl set 5%-")
        (mkExecWith { locked = true; } "XF86AudioPlay" "${pkgs.playerctl}/bin/playerctl play-pause")
        (mkExecWith { locked = true; } "XF86AudioNext" "${pkgs.playerctl}/bin/playerctl next")
        (mkExecWith { locked = true; } "XF86AudioPrev" "${pkgs.playerctl}/bin/playerctl previous")
      ]
      ++ lib.optionals (fileManager != null) [
        (mkExec "SUPER + SHIFT + F" fileManager)
      ]
      ++ workspaceBindings
      ++ [
        (mkBindWith { mouse = true; } "SUPER + mouse:272" "hl.dsp.window.drag()")
        (mkBindWith { mouse = true; } "SUPER + mouse:273" "hl.dsp.window.resize()")
      ];
    };
  };

  # UWSM owns the graphical systemd session; make Home Manager's environment
  # available without enabling Home Manager's conflicting session target.
  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  services.hyprpaper = {
    enable = true;
    systemdTarget = "graphical-session.target";
    settings = {
      splash = false;
      wallpaper = [
        {
          monitor = "";
          path = desktopTheme.wallpaper.path;
          fit_mode = "cover";
        }
      ];
    };
  };

  # The initial Quickshell implementation owns the bar and launcher. Mako
  # remains the notification daemon until notifications move into the shell.
  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      border-radius = 0;
      padding = "12";
      margin = "16";
      background-color = "${theme.colors.background}f2";
      text-color = theme.colors.foreground;
      border-color = theme.colors.accent;
    };
  };

  home.packages = with pkgs; [
    brightnessctl
    grim
    libnotify
    nautilus
    playerctl
    screenshotArea
    screenshotFull
    slurp
    wl-clipboard
  ];
}
