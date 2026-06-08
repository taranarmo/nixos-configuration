{ pkgs, ... }:
{
  home.packages = with pkgs; [
    font-awesome
    swaynotificationcenter
    kitty
    pwvucontrol
    yad
  ];
  # Waybar (0.15.0) aborts on monitor hotplug: the battery module's worker thread
  # throws an uncaught std::runtime_error ("Could not watch events for .../BAT0")
  # when re-enumerating /sys/class/power_supply races the ucsi-source-psy-* USB-C
  # supplies appearing/disappearing during PD negotiation (see the "bat"/"adapter"
  # pinning in the battery module below). Without this, systemd restarts it a few
  # times during the event storm, trips the default start-rate limit (5 starts /
  # 10s), gives up, and leaves no panel at all. Disabling the rate limit lets it
  # keep restarting until the display settles and it comes back up.
  systemd.user.services.waybar = {
    Unit.StartLimitIntervalSec = 0;
    Service.RestartSec = 2;
  };

  programs.waybar = {
    enable = true;
    systemd.enable = true;
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
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "custom/notification"
          "tray"
          "bluetooth"
          "temperature"
          "cpu"
          "memory"
          "backlight"
          "wireplumber"
          "wireplumber#source"
          "network"
          "idle_inhibitor"
          "battery"
          "hyprland/language"
          "sway/language"
          "clock"
        ];
        "hyprland/language" = {
          "format-eu" = "EU";
          "format-ru" = "RU";
        };
        "backlight" = {
          "format" = "{percent}󰳲";
          "fotmat-icons" = [
            "󰃚"
            "󰃛"
            "󰃜"
            "󰃝"
            "󰃞"
            "󰃟"
            "󰃠"
          ];
        };
        "bluetooth" = {
          "format-on" = "󰂯";
          "format-off" = "󰂲";
          "format-connected" = "󰂱";
          "format-connected-battery" = " {device_alias} {device_battery_percentage}%";
          "tooltip-format" = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          "tooltip-format-connected" =
            "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          "tooltip-format-enumerate-connected" = "{device_alias}\t{device_address}";
          "tooltip-format-enumerate-connected-battery" =
            "{device_alias}\t{device_address}\t{device_battery_percentage}%";
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
          "tooltip-format" = "<tt><span size='200%'>{calendar}</span></tt>";
          "calendar" = {
            "mode" = "month";
            "mode-mon-col" = 3;
            "weeks-pos" = "right";
            "on-scroll" = 1;
            "format" = {
              "months" = "<span color='#f9e2af'><b>{}</b></span>";
              "days" = "<span color='#cdd6f4'><b>{}</b></span>";
              "weeks" = "<span color='#74c7ec'><b>W{}</b></span>";
              "weekdays" = "<span color='#fab387'><b>{}</b></span>";
              "today" = "<span color='#f38ba8'><b><u>{}</u></b></span>";
            };
          };
          "on-click" = "GDK_BACKEND=wayland ${pkgs.yad}/bin/yad --calendar --width=600 --height=500 --undecorated --fixed --close-on-unfocus --no-buttons --posx=650 --posy=60 --title='Calendar' --font-name='Arimo Nerd Font 16'";
          "actions" = {
            "on-click-right" = "mode";
            "on-scroll-up" = "shift_up";
            "on-scroll-down" = "shift_down";
          };
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
          # Pin the real battery/adapter so the module stops auto-enumerating the
          # volatile ucsi-source-psy-* USB-C power supplies that flap in and out
          # during DP-alt/PD negotiation on display hotplug. The battery worker
          # throws an uncaught std::runtime_error ("Could not watch events for
          # .../BAT0") when that enumeration races a device removal, which aborts
          # the whole bar. See the systemd auto-restart note above for the safety net.
          "bat" = "BAT0";
          "adapter" = "ADP1";
          "format" = "{capacity}% {icon}";
          "format-alt" = "{time} {icon}";
          "format-icons" = [
            "󰂎"
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          "format-charging" = "{capacity}% {icon}󰚥";
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
          "format-icons" = [
            ""
            ""
            ""
            ""
            ""
          ];
        };
        "network" = {
          "format" = "{icon}";
          "format-alt" = "{ipaddr}/{cidr} {icon}";
          "format-alt-click" = "click-right";
          "format-icons" = {
            "wifi" = [
              "󰤟"
              "󰤢"
              "󰤥"
              "󰤨"
            ];
            "ethernet" = [ "󰈀" ];
            "disconnected" = [ "󰌙 " ];
          };
          "on-click" = "kitty -e nmtui";
          "tooltip" = false;
        };
        "wireplumber" = {
          "format" = "{icon}";
          "format-alt" = "{volume} {icon}";
          "format-alt-click" = "click-right";
          "format-muted" = "󰝟";
          "format-icons" = {
            "phone" = [
              " 󰕿"
              " 󰖀"
              " 󰕾"
            ];
            "default" = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          "scroll-step" = 1;
          "on-click" = "pwvucontrol";
          "tooltip-format" = "{node_name}\nVolume: {volume}%";
        };
        "wireplumber#source" = {
          "node-type" = "Audio/Source";
          "format" = "";
          "format-alt" = "{volume}% ";
          "format-alt-click" = "click-right";
          "format-muted" = "";
          "on-click" = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          "scroll-step" = 1;
          "tooltip-format" = "{node_name}\nVolume: {volume}%";
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
        "custom/notification" = {
          "tooltip" = false;
          "format" = "{} {icon}";
          "format-icons" = {
            "notification" = "<span foreground='red'><sup></sup></span>";
            "none" = "";
            "dnd-notification" = "<span foreground='red'><sup></sup></span>";
            "dnd-none" = "";
            "inhibited-notification" = "<span foreground='red'><sup></sup></span>";
            "inhibited-none" = "";
            "dnd-inhibited-notification" = "<span foreground='red'><sup></sup></span>";
            "dnd-inhibited-none" = "";
          };
          "return-type" = "json";
          "exec-if" = "which swaync-client";
          "exec" = "swaync-client -swb";
          "on-click" = "swaync-client -t -sw";
          "on-click-right" = "swaync-client -d -sw";
          "escape" = true;
        };
      };
    };
    style = ''
      *{
        font-family: "Arimo Nerd Font", "Font Awesome 7 Free", sans-serif;
      }
      #workspaces button.active {
        background: #64727D;
      }
      #tooltip {
        background: rgba(30, 30, 46, 0.9);
        border: 2px solid #cba6f7;
        border-radius: 10px;
        padding: 20px;
      }
      #tooltip label {
        font-size: 16px;
      }
    '';
  };
}
