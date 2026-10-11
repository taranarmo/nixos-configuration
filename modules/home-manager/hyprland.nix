{ config, lib, pkgs, osConfig, ... }:

let
  inherit (lib.generators) mkLuaInline;

  bind = chord: disp: { _args = [ chord (mkLuaInline disp) ]; };
  bindo = chord: disp: opts: { _args = [ chord (mkLuaInline disp) opts ]; };
in

{
  home.packages = with pkgs; [
    hyprland-per-window-layout
    wl-clipboard
    wlr-randr # monitor management
    grim # screenshots
    grimblast
    swaylock
    swayidle
    nwg-bar
    wofi
    brightnessctl
    playerctl
    wireplumber
    wl-screenrec
    slurp
    wdisplays
  ];
  services.cliphist = {
    enable = true;
    allowImages = true;
  };
  programs.swayimg.enable = true;
  programs.rofi = {
    enable = true;
    settings = {
      modes = [
        "window"
        "drun"
        "run"
        "ssh"
        "filebrowser"
        "recursivebrowser"
        "combi"
        "keys"
        "calc"
        "emoji"
      ];
    };
    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
      rofi-network-manager
    ];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    configType = "lua";

    settings = {
      config = {
        general = {
          gaps_in = 3;
          gaps_out = 5;
          border_size = 2;
          layout = "dwindle";
          allow_tearing = false;
          resize_on_border = true;
        };
        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 3;
            passes = 1;
          };
        };
        animations.enabled = true;
        dwindle.preserve_split = true;
        master.new_status = "master";
        misc = {
          force_default_wallpaper = 0;
          vrr = 3;
        };
        ecosystem.no_update_news = true;
        input = {
          kb_layout = "eu,ru";
          kb_variant = "";
          kb_model = "pc101";
          kb_options = "grp:lalt_lshift_toggle,grp:rwin_switch,lv3:ralt_switch,compose:lwin-altgr,compose:rctrl-altgr,compose:paus,ctrl:nocaps";
          kb_rules = "";
          follow_mouse = 1;
          touchpad = {
            natural_scroll = false;
            disable_while_typing = 1;
          };
          sensitivity = 0;
        };
      };

      curve = {
        _args = [
          "myBezier"
          {
            type = "bezier";
            points = [ [ 0.05 0.9 ] [ 0.1 1.05 ] ];
          }
        ];
      };

      animation = [
        { leaf = "windows";     enabled = true; speed = 1;  bezier = "myBezier"; }
        { leaf = "windowsOut";  enabled = true; speed = 1;  bezier = "default"; style = "popin 80%"; }
        { leaf = "border";      enabled = true; speed = 10; bezier = "default"; }
        { leaf = "borderangle"; enabled = true; speed = 8;  bezier = "default"; }
        { leaf = "fade";        enabled = true; speed = 2;  bezier = "default"; }
        { leaf = "workspaces";  enabled = true; speed = 3;  bezier = "default"; }
      ];

      monitor = [
        {
          output = osConfig.custom.display.internalMonitor;
          mode = "preferred";
          position = "auto";
          scale = osConfig.custom.display.scaling;
        }
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = 1;
        }
      ];

      gesture = [
        { fingers = 4; direction = "swipe";      action = "move"; }
        { fingers = 5; direction = "horizontal"; action = "workspace"; }
        { fingers = 5; direction = "pinch";      action = "fullscreen"; }
        {
          fingers = 3;
          direction = "left";
          action = mkLuaInline ''function() hl.dispatch(hl.dsp.send_shortcut({ mods = "", key = "XF86Back" })) end'';
        }
        {
          fingers = 3;
          direction = "right";
          action = mkLuaInline ''function() hl.dispatch(hl.dsp.send_shortcut({ mods = "", key = "XF86Forward" })) end'';
        }
      ];

      exec_cmd = [
        "hyprland-per-window-layout"
        "swayidle -w timeout 90 'brightnessctl -s & brightnessctl set 5%' resume 'brightnessctl -r' timeout 180 'swaylock -f -c 000000' timeout 200 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' timeout 1200 'systemctl suspend' before-sleep 'swaylock -f -c 000000'"
        "[ -d /tmp/screenshots ] || mkdir /tmp/screenshots"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      bind = [
        # Move focus with arrow keys
        (bind "SUPER + left"  ''hl.dsp.focus({ direction = "l" })'')
        (bind "SUPER + right" ''hl.dsp.focus({ direction = "r" })'')
        (bind "SUPER + up"    ''hl.dsp.focus({ direction = "u" })'')
        (bind "SUPER + down"  ''hl.dsp.focus({ direction = "d" })'')
        # Move focus with vi-like keys
        (bind "SUPER + H" ''hl.dsp.focus({ direction = "l" })'')
        (bind "SUPER + L" ''hl.dsp.focus({ direction = "r" })'')
        (bind "SUPER + K" ''hl.dsp.focus({ direction = "u" })'')
        (bind "SUPER + J" ''hl.dsp.focus({ direction = "d" })'')
        # Move window with arrow keys
        (bind "SUPER + SHIFT + Left"  ''hl.dsp.window.move({ direction = "l" })'')
        (bind "SUPER + SHIFT + Right" ''hl.dsp.window.move({ direction = "r" })'')
        (bind "SUPER + SHIFT + Up"    ''hl.dsp.window.move({ direction = "u" })'')
        (bind "SUPER + SHIFT + Down"  ''hl.dsp.window.move({ direction = "d" })'')
        # Move window with vi-like keys
        (bind "SUPER + SHIFT + H" ''hl.dsp.window.move({ direction = "l" })'')
        (bind "SUPER + SHIFT + L" ''hl.dsp.window.move({ direction = "r" })'')
        (bind "SUPER + SHIFT + K" ''hl.dsp.window.move({ direction = "u" })'')
        (bind "SUPER + SHIFT + J" ''hl.dsp.window.move({ direction = "d" })'')

        # Move current workspace between monitors with vi-like keys
        (bind "SUPER + CONTROL + SHIFT + H" ''hl.dsp.workspace.move({ monitor = "l" })'')
        (bind "SUPER + CONTROL + SHIFT + L" ''hl.dsp.workspace.move({ monitor = "r" })'')
        (bind "SUPER + CONTROL + SHIFT + K" ''hl.dsp.workspace.move({ monitor = "u" })'')
        (bind "SUPER + CONTROL + SHIFT + J" ''hl.dsp.workspace.move({ monitor = "d" })'')

        (bind "SUPER + F"             ''hl.dsp.window.fullscreen({ action = "toggle" })'')
        (bind "SUPER + SHIFT + Space" ''hl.dsp.window.float({ action = "toggle" })'')
        (bind "SUPER + Space"         ''hl.dsp.layout("togglesplit")'')

        (bind "SUPER + Q"         ''hl.dsp.exec_cmd("kitty")'')
        (bind "SUPER + Return"    ''hl.dsp.exec_cmd("kitty")'')
        (bind "SUPER + SHIFT + Q" ''hl.dsp.window.close()'')
        (bind "SUPER + M"         ''hl.dsp.exit()'')
        (bind "SUPER + D"         ''hl.dsp.exec_cmd("rofi -show drun")'')
        (bind "SUPER + V"         ''hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy")'')

        (bind "CONTROL + ALT + L"      ''hl.dsp.exec_cmd("swaylock -f -c 000000")'')
        (bind "CONTROL + ALT + Delete" ''hl.dsp.exec_cmd("nwg-bar")'')

        (bind "Print" ''hl.dsp.exec_cmd("grimblast copy area")'')

        # Screenshots
        (bind "SUPER + CONTROL + SHIFT + c" ''hl.dsp.exec_cmd("wl-copy < $(grimblast --notify save area /tmp/screenshots/screenshot-$(date --iso-8601=seconds).png)")'')
        (bind "SUPER + c"                   ''hl.dsp.exec_cmd("wl-copy < $(grimblast --notify save active /tmp/screenshots/screenshot-$(date --iso-8601=seconds).png)")'')
        (bind "SUPER + SHIFT + c"           ''hl.dsp.exec_cmd("wl-copy < $(grimblast --notify save output /tmp/screenshots/screenshot-$(date --iso-8601=seconds).png)")'')

        # Control Center
        (bind "SUPER + grave" ''hl.dsp.exec_cmd("swaync-client -t -sw")'')

        # Move window with mouse
        (bindo "SUPER + mouse:272" ''hl.dsp.window.drag()'' { mouse = true; })

        # Submap trigger
        (bind "SUPER + R" ''hl.dsp.submap("resize")'')

        # Media keys (work while screen locked)
        (bindo "XF86AudioMute"    ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SINK@ toggle")''   { locked = true; })
        # Push-to-talk: unmute mic while held, mute on release. SHIFT toggles mute.
        (bindo "XF86AudioMicMute"         ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ 0")''      { locked = true; })
        (bindo "XF86AudioMicMute"         ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ 1")''      { locked = true; release = true; })
        (bindo "SHIFT + XF86AudioMicMute" ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle")'' { locked = true; })
        (bindo "XF86AudioPlay"    ''hl.dsp.exec_cmd("playerctl play-pause")''                   { locked = true; })
        (bindo "XF86AudioNext"    ''hl.dsp.exec_cmd("playerctl next")''                         { locked = true; })
        (bindo "XF86AudioPrev"    ''hl.dsp.exec_cmd("playerctl previous")''                     { locked = true; })

        # Volume / brightness (locked + repeating on hold)
        (bindo "XF86AudioRaiseVolume"         ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 1%+")'' { locked = true; repeating = true; })
        (bindo "SHIFT + XF86AudioRaiseVolume" ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%+")'' { locked = true; repeating = true; })
        (bindo "XF86AudioLowerVolume"         ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 1%-")'' { locked = true; repeating = true; })
        (bindo "SHIFT + XF86AudioLowerVolume" ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%-")'' { locked = true; repeating = true; })
        (bindo "XF86MonBrightnessDown"        ''hl.dsp.exec_cmd("brightnessctl set 5%-")''               { locked = true; repeating = true; })
        (bindo "XF86MonBrightnessUp"          ''hl.dsp.exec_cmd("brightnessctl set 5%+")''               { locked = true; repeating = true; })
      ]
      ++ (
        # workspaces: SUPER + {1..0} switches, SUPER + SHIFT + {1..0} moves window silently
        builtins.concatLists (
          builtins.genList (
            x:
            let
              ws =
                let
                  c = (x + 1) / 10;
                in
                toString (x + 1 - (c * 10));
              n = toString (x + 1);
            in
            [
              (bind "SUPER + ${ws}"         ''hl.dsp.focus({ workspace = "${n}" })'')
              (bind "SUPER + SHIFT + ${ws}" ''hl.dsp.window.move({ workspace = "${n}", follow = false })'')
            ]
          ) 10
        )
      );
    };

    submaps.resize = {
      onDispatch = "";
      settings.bind = [
        (bindo "h"         ''hl.dsp.window.resize({ x = 10,  y = 0,   relative = true })'' { repeating = true; })
        (bindo "l"         ''hl.dsp.window.resize({ x = -10, y = 0,   relative = true })'' { repeating = true; })
        (bindo "k"         ''hl.dsp.window.resize({ x = 0,   y = -10, relative = true })'' { repeating = true; })
        (bindo "j"         ''hl.dsp.window.resize({ x = 0,   y = 10,  relative = true })'' { repeating = true; })
        (bindo "SHIFT + h" ''hl.dsp.window.resize({ x = 50,  y = 0,   relative = true })'' { repeating = true; })
        (bindo "SHIFT + l" ''hl.dsp.window.resize({ x = -50, y = 0,   relative = true })'' { repeating = true; })
        (bindo "SHIFT + k" ''hl.dsp.window.resize({ x = 0,   y = -50, relative = true })'' { repeating = true; })
        (bindo "SHIFT + j" ''hl.dsp.window.resize({ x = 0,   y = 50,  relative = true })'' { repeating = true; })
        (bind  "escape"    ''hl.dsp.submap("reset")'')
      ];
    };
  };
}
