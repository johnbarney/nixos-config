{ config, lib, pkgs, plasma-manager, ... }:
let
  screenshotDir = "${config.home.homeDirectory}/Pictures/Screenshots";
  theme = {
    fontSans = "Noto Sans";
    fontMono = "Noto Sans Mono";
    background = "#232629";
    foreground = "#eff0f1";
    accent = "#3daee9";
    accentSoft = "#3daee933";
    inactive = "#585b70aa";
    white = "#ffffffff";
  };
  terminalBin = "${pkgs.kitty}/bin/kitty";
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
in {
  home.username = "johnbarney";
  home.homeDirectory = "/home/johnbarney";

  imports = [
    plasma-manager.homeModules.plasma-manager
  ];

  programs.home-manager.enable = true;
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      brettm12345.nixfmt-vscode
      esbenp.prettier-vscode
      oderwat.indent-rainbow
      ms-vscode."makefile-tools"
      ms-python.python
      golang.go
    ];
  };
  programs.zsh = {
    enable = true;
    initContent = ''
      codex() {
        local codex_bin
        codex_bin="$(whence -p codex 2>/dev/null || true)"
        if [ -n "$codex_bin" ]; then
          "$codex_bin" "$@"
        else
          npx -y @openai/codex "$@"
        fi
      }
    '';
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      identityAgent = "~/.1password/agent.sock";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Breeze-Dark";
      package = pkgs.kdePackages.breeze-gtk;
    };
    iconTheme = {
      name = "breeze-dark";
      package = pkgs.kdePackages.breeze-icons;
    };
    cursorTheme = {
      name = "breeze_cursors";
      package = pkgs.kdePackages.breeze;
      size = 24;
    };
    font = {
      name = theme.fontSans;
      size = 10;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "Breeze";
  };

  programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      iconTheme = "breeze";
      cursor = {
        theme = "breeze_cursors";
        size = 24;
      };
      wallpaper = "/etc/wallpapers/dark_jungle.jpeg";
    };
    fonts = {
      general = {
        family = theme.fontSans;
        pointSize = 10;
      };
      fixedWidth = {
        family = theme.fontMono;
        pointSize = 10;
      };
      windowTitle = {
        family = theme.fontSans;
        pointSize = 10;
      };
    };
    configFile = {
      # Disable Plasma/KWin hot corners.
      "kwinrc"."ElectricBorders" = {
        TopLeft = "None";
        TopRight = "None";
        BottomLeft = "None";
        BottomRight = "None";
      };
    };
  };

  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      macos_option_as_alt = true;
      font_family = theme.fontMono;
      font_size = 10;
      background = theme.background;
      foreground = theme.foreground;
      selection_background = theme.accent;
      selection_foreground = theme.foreground;
      cursor = theme.accent;
      cursor_text_color = theme.background;
      active_border_color = theme.accent;
      inactive_border_color = "#4b4f54";
      window_padding_width = 10;
    };
  };

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
        "selection-text" = theme.white;
        match = "3daee9ff";
        border = "3daee9ff";
      };
      border = {
        width = 2;
        radius = 10;
      };
    };
  };

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
        font-family: "Noto Sans";
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(35, 38, 41, 0.92);
        color: #eff0f1;
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
        color: #eff0f1;
        background: #3daee9;
      }

      #window {
        color: #fcfcfc;
      }

      #tray {
        padding-right: 14px;
      }
    '';
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "/etc/wallpapers/dark_jungle.jpeg" ];
      wallpaper = [ ",/etc/wallpapers/dark_jungle.jpeg" ];
    };
  };

  services.mako = {
    enable = true;
    settings = {
      "default-timeout" = 5000;
      "border-radius" = 10;
      padding = "12";
      margin = "16";
      "background-color" = "#232629f2";
      "text-color" = "#eff0f1ff";
      "border-color" = "#3daee9ff";
    };
  };

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
        "XCURSOR_SIZE,24"
        "XCURSOR_THEME,breeze_cursors"
        "GTK_THEME,Breeze-Dark"
        "ICON_THEME,breeze-dark"
        "QT_STYLE_OVERRIDE,Breeze"
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
          "$mainMod, B, exec, ${pkgs.chromium}/bin/chromium"
          "$mainMod, E, exec, ${pkgs.kdePackages.dolphin}/bin/dolphin"
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
    nodejs_22
    brightnessctl
    kdePackages.breeze
    kdePackages.breeze-gtk
    kdePackages.breeze-icons
    grim
    playerctl
    slurp
    wl-clipboard
    hyprCheatsheet
    screenshotFull
    screenshotArea
  ];

  home.stateVersion = "25.11";

  home.activation.installVscodeExtensions =
    let
      codeBin = "${pkgs.vscode}/bin/code";
    in
    # Codex is published as openai.chatgpt in VS Code Marketplace.
    ''
      if [ -x "${codeBin}" ]; then
        "${codeBin}" --install-extension ms-vscode.makefile-tools --force >/dev/null 2>&1 || true
        "${codeBin}" --install-extension openai.chatgpt --force >/dev/null 2>&1 || true
      fi
    '';
}
