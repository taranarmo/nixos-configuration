{ config, pkgs, ... }:
{
  programs.waybar = {
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        spacing = 5;
        reload_style_on_change = true;
        modules-left = [
          "sway/workspaces"
          "sway/mode"
          "hyprland/workspaces"
          "hyprland/submap"
        ];
        modules-center = [ "sway/window" "hyprland/window" ];
        modules-right = [
          "custom/notification"
          "tray"
          "bluetooth"
          "temperature"
          "cpu"
          "memory"
          "backlight"
          "pulseaudio"
          "network"
          "idle_inhibitor"
          "battery"
          "hyprland/language"
          "sway/language"
          "clock"
        ];
        "bluetooth" = {
            "format" = " {status}";
            "format-connected" = " {device_alias}";
            "format-connected-battery" = " {device_alias} {device_battery_percentage}%";
            "tooltip-format" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
            "tooltip-format-connected" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
            "tooltip-format-enumerate-connected" = "{device_alias}\t{device_address}";
            "tooltip-format-enumerate-connected-battery" = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
        };
        "sway/mode" = {
            "format" = " {}";
        };
        "hyprland/workspaces" = {
            "format" = "{name}";
            "disable-scroll" = true;
        };
        "sway/workspaces" = {
            "format" = "{name}";
            "disable-scroll" = true;
        };
        "sway/window" = {
            "max-length" = 80;
            "tooltip" = false;
        };
        "clock" = {
            "format" = "{:%a %d %b %H:%M}";
            "tooltip" = false;
        };
        "cpu" = {
            "interval" = 1;
            "format" = "{usage:>2}% ";
            "max-length" = 10;
        };
        "memory" = {
            "interval" = 5;
            "format" = "{}% ";
        };
        "battery" = {
            "format" = "{capacity}% {icon}";
            "format-alt" = "{time} {icon}";
            "format-icons" = ["" "" "" "" ""];
            "format-charging" = "{capacity}% 󰂄";
            "interval" = 30;
            "states" = {
                "warning" = 25;
                "critical" = 10;
            };
            "tooltip" = false;
        };
        "temperature" = {
            "thermal-zone" = 6;
            "critical-threshold" = 80;
            "format" = "{temperatureC}°C {icon}";
            "format-icons" = ["" "" "" "" ""];
        };
        "network" = {
            "format" = "{icon}";
            "format-alt" = "{ipaddr}/{cidr} {icon}";
            "format-alt-click" = "click-right";
            "format-icons" = {
                "wifi" = ["󰤟" "󰤢" "󰤥" "󰤨"];
                "ethernet" = ["󰈀"];
                "disconnected" = ["󰌙 "];
            };
            "on-click" = "alacritty -e nmtui";
            "tooltip" = false;
        };
        "pulseaudio" = {
            "format" = "{icon}";
            "format-alt" = "{volume} {icon}";
            "format-alt-click" = "click-right";
            "format-muted" = "󰝟";
            "format-icons" = {
                "phone" = [" 󰕿" " 󰖀" " 󰕾"];
                "default" = ["󰕿" "󰖀" "󰕾"];
            };
            "scroll-step" = 10;
            "on-click" = "pavucontrol";
            "tooltip" = false;
        };
        "idle_inhibitor" = {
            "format" = "{icon}";
            "timeout" = 90;
            "format-icons" = {
                "activated" = "";
                "deactivated" = "";
            };
            "tooltip" = false;
        };
        "tray" = {
            "icon-size" = 18;
        };
        "hyprland/window" = {
          "max-length" = 200;
          "separate-outputs" = true;
        };
        "custom/notification" =  {
            "tooltip" =  false;
            "format" =  "{} {icon}";
            "format-icons" =  {
                "notification" =  "<span  foreground='red'><sup></sup></span>";
                "none" =  "";
                "dnd-notification" =  "<span  foreground='red'><sup></sup></span>";
                "dnd-none" =  "";
                "inhibited-notification" =  "<span  foreground='red'><sup></sup></span>";
                "inhibited-none" =  "";
                "dnd-inhibited-notification" =  "<span  foreground='red'><sup></sup></span>";
                "dnd-inhibited-none" =  "";
            };
            "return-type" =  "json";
            "exec-if" =  "which  swaync-client";
            "exec" =  "swaync-client  -swb";
            "on-click" =  "swaync-client  -t  -sw";
            "on-click-right" =  "swaync-client  -d  -sw";
            "escape" =  true;
        };
      };
    };
  };
}
