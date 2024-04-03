{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      bind =
        [
          # Move focus with mainMod + arrow keys
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"
          # Move focus with mainMod + vi-like keys
          "$mod, h, movefocus, l"
          "$mod, l, movefocus, r"
          "$mod, k, movefocus, u"
          "$mod, j, movefocus, d"
          # Move window with arrow keys
          "$mod Shift, left, movewindow, l"
          "$mod Shift, right, movewindow, r"
          "$mod Shift, up, movewindow, u"
          "$mod Shift, down, movewindow, d"
          # Move window with vi-like keys
          "$mod Shift, h, movewindow, l"
          "$mod Shift, l, movewindow, r"
          "$mod Shift, k, movewindow, u"
          "$mod Shift, j, movewindow, d"

          "$mod, f, fullscreen, "

          "$mod, Q, exec, kitty"
          "$mod, Return, exec, alacritty"
          "$mod, C, killactive, "
          "$mod, M, exit, "
          "$mod, D, exec, wofi --show drun"
          #"$mod, R, exec, wofi --show drun"

          #"$mod, L, exec, swaylock -f -c 000000"
          "CTRL + ALT, L, exec, swaylock -f -c 000000"

          ", Print, exec, grimblast copy area"

          ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
          ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"
          ", XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"
          ", XF86AudioMicMute, exec, pactl set-source-mute @DEFAULT_SOURCE@ toggle"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
          ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"
          #", XF86Search, exec, $menu"

        ]
        ++ (
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
            )
            10)
        );
    };
    extraConfig = ''
# See https://wiki.hyprland.org/Configuring/Monitors/
monitor=,preferred,auto,1

# See https://wiki.hyprland.org/Configuring/Keywords/ for more

# Execute your favorite apps at launch
# exec-once = waybar & hyprpaper & firefox
exec-once = waybar

# Idle
exec-once = swayidle -w timeout 300 'swaylock -f -c 000000' \
            timeout 600 'hyprctl dispatch dpms off' \
            resume 'hyprctl dispatch dpms on' \
            timeout 900 'systemctl suspend' \
            before-sleep 'swaylock -f -c 000000' &

# Source a file (multi-file configs)
# source = ~/.config/hypr/myColors.conf

# Some default env vars.
env = XCURSOR_SIZE,24

# For all categories, see https://wiki.hyprland.org/Configuring/Variables/
input {
    kb_layout = eu,ru
    kb_variant =
    kb_model = pc101
    kb_options = grp:caps_switch,grp:lalt_lshift_toggle,lv3:ralt_switch,compose:lwin-altgr,compose:rctrl-altgr
    kb_rules =

    follow_mouse = 1

    touchpad {
        natural_scroll = no
    }

    sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
}

general {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more

    gaps_in = 3
    gaps_out = 5
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)

    layout = dwindle

    # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
    allow_tearing = true
}

decoration {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more

    rounding = 10

    blur {
        enabled = true
        size = 3
        passes = 1
    }

    drop_shadow = yes
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

animations {
    enabled = yes
    # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more

    bezier = myBezier, 0.05, 0.9, 0.1, 1.05

    animation = windows, 1, 1, myBezier
    animation = windowsOut, 1, 1, default, popin 80%
    animation = border, 1, 10, default
    animation = borderangle, 1, 8, default
    animation = fade, 1, 2, default
    animation = workspaces, 1, 3, default
}

dwindle {
    # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
    pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
    preserve_split = yes # you probably want this
}

master {
    # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
    new_is_master = true
}

gestures {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more
    workspace_swipe = off
}

misc {
    # See https://wiki.hyprland.org/Configuring/Variables/ for more
    force_default_wallpaper = 0 # Set to 0 to disable the anime mascot wallpapers
}

# Example per-device config
# See https://wiki.hyprland.org/Configuring/Keywords/#executing for more
device:epic-mouse-v1 {
    sensitivity = -0.5
}

# Example windowrule v1
# windowrule = float, ^(kitty)$
# Example windowrule v2
# windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
# See https://wiki.hyprland.org/Configuring/Window-Rules/ for more


# See https://wiki.hyprland.org/Configuring/Keywords/ for more
$mainMod = SUPER

# Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
bind = $mainMod, E, exec, dolphin
#bind = $mainMod, V, togglefloating, 
bind = $mainMod, P, pseudo, # dwindle
#bind = $mainMod, J, togglesplit, # dwindle

# Example special workspace (scratchpad)
bind = $mainMod, S, togglespecialworkspace, magic
bind = $mainMod SHIFT, S, movetoworkspace, special:magic

bind=$mainMod,R,submap,resize # will switch to a submap called resize
submap=resize # will start a submap called "resize"
binde=,l,resizeactive,10 0
binde=,h,resizeactive,-10 0
binde=,k,resizeactive,0 -10
binde=,j,resizeactive,0 10
binde=Shift,l,resizeactive,50 0
binde=Shift,h,resizeactive,-50 0
binde=Shift,k,resizeactive,0 -50
binde=Shift,j,resizeactive,0 50
bind=,escape,submap,reset # use reset to go back to the global submap
submap=reset # will reset the submap, meaning end the current one and return to the global one.

    '';
  };
}
