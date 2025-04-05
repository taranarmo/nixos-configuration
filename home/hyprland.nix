{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    hyprland-per-window-layout
    wl-clipboard
    grim # screenshots
    grimblast
    swaylock
    swayidle
    waybar
    nwg-bar
    wofi
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = false;
    settings = {
      "$mod" = "SUPER";
      bind = [
        # Move focus with mainMod + arrow keys
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        # Move focus with mainMod + vi-like keys
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"
        # Move window with arrow keys
        "$mod Shift, Left, movewindow, l"
        "$mod Shift, Right, movewindow, r"
        "$mod Shift, Up, movewindow, u"
        "$mod Shift, Down, movewindow, d"
        # Move window with vi-like keys
        "$mod Shift, H, movewindow, l"
        "$mod Shift, L, movewindow, r"
        "$mod Shift, K, movewindow, u"
        "$mod Shift, J, movewindow, d"

        # Move workspace between monitors with vi-like keys
        "$mod Control Shift, H, movecurrentworkspacetomonitor, l"
        "$mod Control Shift, L, movecurrentworkspacetomonitor, r"
        "$mod Control Shift, K, movecurrentworkspacetomonitor, u"
        "$mod Control Shift, J, movecurrentworkspacetomonitor, d"

        "$mod, F, fullscreen, "
        "$mod Shift, Space, togglefloating, "
        "$mod, Space, togglesplit, " # dwindle

        "$mod, Q, exec, kitty"
        "$mod, Return, exec, alacritty"
        "$mod Shift, Q, killactive, "
        "$mod, M, exit, "
        "$mod, D, exec, wofi --show drun"
        #"$mod, R, exec, wofi --show drun"

        #"$mod, L, exec, swaylock -f -c 000000"
        "Control + Alt, L, exec, swaylock -f -c 000000"
        "Control + Alt, Delete, exec, nwg-bar"

        "Control, Space, exec, hyprctl switchxkblayout current next"

        ", Print, exec, grimblast copy area"

        # Screenshots
        "$mod Control Shift, c, exec, wl-copy < $(grimblast --notify save area /tmp/screenshots/screenshot-$(date --iso-8601=seconds).png)" # Area
        "$mod, C, exec, wl-copy < $(grimblast --notify save active /tmp/screenshots/screenshot-$(date --iso-8601=seconds).png)" # Active window
      ] ++ (
          # workspaces
          # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
          builtins.concatLists (builtins.genList (
              x: let
                ws = let
                  c = (x + 1) / 10;
                in
                  builtins.toString (x + 1 - (c * 10));
              in [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$mod SHIFT, ${ws}, movetoworkspacesilent, ${toString (x + 1)}"
              ]
          ) 10)
        );
      bindl = [
        ", XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"
        ", XF86AudioMicMute, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];
      bindel = [
        ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
        ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
      ];
      bindm = [
        "$mod, mouse:272, movewindow" # move window with mouse
      ];
      exec-once = [
        "waybar"
        "hyprland-per-window-layout"
        "swayidle -w timeout 90 'brightnessctl -s & brightnessctl set 5%' resume 'brightnessctl -r' timeout 180 'swaylock -f -c 000000' timeout 200 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' timeout 1200 'systemctl suspend' before-sleep 'swaylock -f -c 000000'"
        "[ -d /tmp/screenshots ] || mkdir /tmp/screenshots"
      ];
      monitor = ",preferred,auto,1";

      input = {
        kb_layout = "eu,ru";
        kb_variant = "";
        kb_model = "pc101";
        kb_options = "grp:lalt_lshift_toggle,grp:rctrl_switch,lv3:ralt_switch,compose:lwin-altgr,compose:rctrl-altgr,ctrl:nocaps";
        kb_rules = "";

        follow_mouse = 1;

        touchpad = {
          natural_scroll = "no";
          disable_while_typing = 1;
        };

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
      };

      general = {
        gaps_in = 3;
        gaps_out = 5;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
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

      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 1, myBezier"
          "windowsOut, 1, 1, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 2, default"
          "workspaces, 1, 3, default"
        ];
      };

      dwindle = {
        pseudotile = true; # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
        preserve_split = true; # you probably want this
      };

      master = {
        new_status = "master";
      };

      gestures = {
        workspace_swipe = "off";
      };

      misc = {
        force_default_wallpaper = 0; # Set to 0 to disable the anime mascot wallpapers
        vrr = 1;
      };

      # Example windowrule v1
      # windowrule = "float, ^(kitty)$";
      # Example windowrule v2
      # windowrulev2 = "float,class:^(kitty)$,title:^(kitty)$";
    };
    extraConfig = ''
      bind = $mod, R, submap, resize
      submap = resize
      binde = , h, resizeactive, 10 0
      binde = , l, resizeactive, -10 0
      binde = , k, resizeactive, 0 -10
      binde = , j, resizeactive, 0 10
      binde = shift, h, resizeactive, 50 0
      binde = shift, l, resizeactive, -50 0
      binde = shift, k, resizeactive, 0 -50
      binde = shift, j, resizeactive, 0 50
      bind = , escape, submap, reset
      submap = reset
    '';
  };
}
