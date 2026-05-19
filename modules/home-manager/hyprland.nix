{ config, pkgs, osConfig, ... }:

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
  ];
  services.cliphist = {
    enable = true;
    allowImages = true;
  };
  programs.swayimg.enable = true;
  programs.rofi = {
    enable = true;
    pass.enable = true;
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
      bind = [
        # Move focus with mainMod + arrow keys
        { mod = "SUPER"; key = "left"; dispatcher = "movefocus"; arg = "l"; }
        { mod = "SUPER"; key = "right"; dispatcher = "movefocus"; arg = "r"; }
        { mod = "SUPER"; key = "up"; dispatcher = "movefocus"; arg = "u"; }
        { mod = "SUPER"; key = "down"; dispatcher = "movefocus"; arg = "d"; }
        # Move focus with mainMod + vi-like keys
        { mod = "SUPER"; key = "H"; dispatcher = "movefocus"; arg = "l"; }
        { mod = "SUPER"; key = "L"; dispatcher = "movefocus"; arg = "r"; }
        { mod = "SUPER"; key = "K"; dispatcher = "movefocus"; arg = "u"; }
        { mod = "SUPER"; key = "J"; dispatcher = "movefocus"; arg = "d"; }
        # Move window with arrow keys
        { mod = "SUPER SHIFT"; key = "Left"; dispatcher = "movewindow"; arg = "l"; }
        { mod = "SUPER SHIFT"; key = "Right"; dispatcher = "movewindow"; arg = "r"; }
        { mod = "SUPER SHIFT"; key = "Up"; dispatcher = "movewindow"; arg = "u"; }
        { mod = "SUPER SHIFT"; key = "Down"; dispatcher = "movewindow"; arg = "d"; }
        # Move window with vi-like keys
        { mod = "SUPER SHIFT"; key = "H"; dispatcher = "movewindow"; arg = "l"; }
        { mod = "SUPER SHIFT"; key = "L"; dispatcher = "movewindow"; arg = "r"; }
        { mod = "SUPER SHIFT"; key = "K"; dispatcher = "movewindow"; arg = "u"; }
        { mod = "SUPER SHIFT"; key = "J"; dispatcher = "movewindow"; arg = "d"; }

        # Move workspace between monitors with vi-like keys
        { mod = "SUPER CONTROL SHIFT"; key = "H"; dispatcher = "movecurrentworkspacetomonitor"; arg = "l"; }
        { mod = "SUPER CONTROL SHIFT"; key = "L"; dispatcher = "movecurrentworkspacetomonitor"; arg = "r"; }
        { mod = "SUPER CONTROL SHIFT"; key = "K"; dispatcher = "movecurrentworkspacetomonitor"; arg = "u"; }
        { mod = "SUPER CONTROL SHIFT"; key = "J"; dispatcher = "movecurrentworkspacetomonitor"; arg = "d"; }

        { mod = "SUPER"; key = "F"; dispatcher = "fullscreen"; arg = ""; }
        { mod = "SUPER SHIFT"; key = "Space"; dispatcher = "togglefloating"; arg = ""; }
        { mod = "SUPER"; key = "Space"; dispatcher = "layoutmsg"; arg = "togglesplit "; }

        { mod = "SUPER"; key = "Q"; dispatcher = "exec"; arg = "kitty"; }
        { mod = "SUPER"; key = "Return"; dispatcher = "exec"; arg = "kitty"; }
        { mod = "SUPER SHIFT"; key = "Q"; dispatcher = "killactive"; arg = ""; }
        { mod = "SUPER"; key = "M"; dispatcher = "exit"; arg = ""; }
        { mod = "SUPER"; key = "D"; dispatcher = "exec"; arg = "rofi -show drun"; }
        { mod = "SUPER"; key = "V"; dispatcher = "exec"; arg = "cliphist list | rofi -dmenu | cliphist decode | wl-copy"; }

        { mod = "CONTROL ALT"; key = "L"; dispatcher = "exec"; arg = "swaylock -f -c 000000"; }
        { mod = "CONTROL ALT"; key = "Delete"; dispatcher = "exec"; arg = "nwg-bar"; }

        { mod = ""; key = "Print"; dispatcher = "exec"; arg = "grimblast copy area"; }

        # Screenshots
        { mod = "SUPER CONTROL SHIFT"; key = "c"; dispatcher = "exec"; arg = "wl-copy < $(grimblast --notify save area /tmp/screenshots/screenshot-$(date --iso-8601=seconds).png)"; }
        { mod = "SUPER"; key = "c"; dispatcher = "exec"; arg = "wl-copy < $(grimblast --notify save active /tmp/screenshots/screenshot-$(date --iso-8601=seconds).png)"; }
        { mod = "SUPER SHIFT"; key = "c"; dispatcher = "exec"; arg = "wl-copy < $(grimblast --notify save output /tmp/screenshots/screenshot-$(date --iso-8601=seconds).png)"; }

        # Control Center
        { mod = "SUPER"; key = "grave"; dispatcher = "exec"; arg = "swaync-client -t -sw"; }

        # Submap trigger
        { mod = "SUPER"; key = "R"; dispatcher = "submap"; arg = "resize"; }
      ]
      ++ (
        # workspaces
        # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
        builtins.concatLists (
          builtins.genList (
            x:
            let
              ws =
                let
                  c = (x + 1) / 10;
                in
                builtins.toString (x + 1 - (c * 10));
            in
            [
              { mod = "SUPER"; key = ws; dispatcher = "workspace"; arg = toString (x + 1); }
              { mod = "SUPER SHIFT"; key = ws; dispatcher = "movetoworkspacesilent"; arg = toString (x + 1); }
            ]
          ) 10
        )
      );
      bindl = [
        { mod = ""; key = "XF86AudioMute"; dispatcher = "exec"; arg = "wpctl set-mute @DEFAULT_SINK@ toggle"; }
        { mod = ""; key = "XF86AudioMicMute"; dispatcher = "exec"; arg = "wpctl set-mute @DEFAULT_SOURCE@ toggle"; }
        { mod = ""; key = "XF86AudioPlay"; dispatcher = "exec"; arg = "playerctl play-pause"; }
        { mod = ""; key = "XF86AudioNext"; dispatcher = "exec"; arg = "playerctl next"; }
        { mod = ""; key = "XF86AudioPrev"; dispatcher = "exec"; arg = "playerctl previous"; }
      ];
      bindel = [
        { mod = ""; key = "XF86AudioRaiseVolume"; dispatcher = "exec"; arg = "wpctl set-volume @DEFAULT_SINK@ 1%+"; }
        { mod = "SHIFT"; key = "XF86AudioRaiseVolume"; dispatcher = "exec"; arg = "wpctl set-volume @DEFAULT_SINK@ 5%+"; }
        { mod = ""; key = "XF86AudioLowerVolume"; dispatcher = "exec"; arg = "wpctl set-volume @DEFAULT_SINK@ 1%-"; }
        { mod = "SHIFT"; key = "XF86AudioLowerVolume"; dispatcher = "exec"; arg = "wpctl set-volume @DEFAULT_SINK@ 5%-"; }
        { mod = ""; key = "XF86MonBrightnessDown"; dispatcher = "exec"; arg = "brightnessctl set 5%-"; }
        { mod = ""; key = "XF86MonBrightnessUp"; dispatcher = "exec"; arg = "brightnessctl set 5%+"; }
      ];
      bindm = [
        { mod = "SUPER"; key = "mouse:272"; dispatcher = "movewindow"; } # move window with mouse
      ];
      exec-once = [
        "waybar"
        "hyprland-per-window-layout"
        "swayidle -w timeout 90 'brightnessctl -s & brightnessctl set 5%' resume 'brightnessctl -r' timeout 180 'swaylock -f -c 000000' timeout 200 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' timeout 1200 'systemctl suspend' before-sleep 'swaylock -f -c 000000'"
        "[ -d /tmp/screenshots ] || mkdir /tmp/screenshots"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];
      monitor = [
        { name = osConfig.custom.display.internalMonitor; res = "preferred"; pos = "auto"; scale = osConfig.custom.display.scaling; }
        { name = ""; res = "preferred"; pos = "auto"; scale = "1"; }
      ];

      input = {
        kb_layout = "eu,ru";
        kb_variant = "";
        kb_model = "pc101";
        kb_options = "grp:lalt_lshift_toggle,grp:rwin_switch,lv3:ralt_switch,compose:lwin-altgr,compose:rctrl-altgr,compose:paus,ctrl:nocaps";
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

      ecosystem = {
        no_update_news = true;
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
        preserve_split = true; # you probably want this
      };

      master = {
        new_status = "master";
      };

      misc = {
        force_default_wallpaper = 0; # Set to 0 to disable the anime mascot wallpapers
        vrr = 3;
      };

      gesture = [
        "3, left, dispatcher, sendshortcut, , XF86Back, activewindow"
        "3, right, dispatcher, sendshortcut, , XF86Forward, activewindow"
        "4, swipe, move"
        "5, horizontal, workspace"
        "5, pinch, fullscreen"
      ];

      submap = {
        resize = {
          binde = [
            { mod = ""; key = "h"; dispatcher = "resizeactive"; arg = "10 0"; }
            { mod = ""; key = "l"; dispatcher = "resizeactive"; arg = "-10 0"; }
            { mod = ""; key = "k"; dispatcher = "resizeactive"; arg = "0 -10"; }
            { mod = ""; key = "j"; dispatcher = "resizeactive"; arg = "0 10"; }
            { mod = "SHIFT"; key = "h"; dispatcher = "resizeactive"; arg = "50 0"; }
            { mod = "SHIFT"; key = "l"; dispatcher = "resizeactive"; arg = "-50 0"; }
            { mod = "SHIFT"; key = "k"; dispatcher = "resizeactive"; arg = "0 -50"; }
            { mod = "SHIFT"; key = "j"; dispatcher = "resizeactive"; arg = "0 50"; }
          ];
          bind = [
            { mod = ""; key = "escape"; dispatcher = "submap"; arg = "reset"; }
          ];
        };
      };

      # Example windowrule v1
      # windowrule = "float, ^(kitty)$";
      # Example windowrule v2
      # windowrulev2 = "float,class:^(kitty)$,title:^(kitty)$";
    };
  };
}
