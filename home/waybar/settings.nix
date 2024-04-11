{ config, pkgs, ... }:
{
  programs.waybar = {
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
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
            "format-charging" = "{capacity}% ";
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
            "format-icons" = ["" "" ""];
        };
        "network" = {
            "format" = "{icon}";
            "format-alt" = "{ipaddr}/{cidr} {icon}";
            "format-alt-click" = "click-right";
            "format-icons" = {
                "wifi" = ["" "" ""];
                "ethernet" = [""];
                "disconnected" = [""];
            };
            "on-click" = "alacritty -e nmtui";
            "tooltip" = false;
        };
        "pulseaudio" = {
            "format" = "{icon}";
            "format-alt" = "{volume} {icon}";
            "format-alt-click" = "click-right";
            "format-muted" = "";
            "format-icons" = {
                "phone" = [" " " " " " " "];
                "default" = ["" "" "" ""];
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
