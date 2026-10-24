{ pkgs, ... }:
let
  # Native `battery` module replacement. Waybar 0.15.0's battery worker aborts the
  # whole bar with an uncaught std::runtime_error ("Could not watch events for
  # .../BAT0") because its inotify_add_watch on the battery node races the
  # ucsi-source-psy-* USB-C supplies churning during PD negotiation on display
  # hotplug (and now even at startup). A plain sysfs poll can't crash the bar.
  # Dedicated charge-cap badge. Shows nothing while charging to 100%, and
  # "(80)" in green while the 80% cap (battery-charge-hold.service) is
  # armed. The native battery module above has no notion of the persisted
  # limit, so this custom module surfaces it.
  batteryScript = pkgs.writeShellScript "waybar-battery-cap" ''
    limit=$(cat /var/lib/battery-charge-hold/limit 2>/dev/null)
    if [ "$limit" = "80" ]; then
      printf '{"text":"(80)","class":"capped"}\n'
    else
      printf '{"text":"","class":""}\n'
    fi
  '';
in
{
  home.packages = with pkgs; [
    font-awesome
    swaynotificationcenter
    kitty
    pwvucontrol
    yad
  ];
  # Safety net for any future crash-on-hotplug: without this, systemd restarts
  # waybar a few times during an output-event storm, trips the default start-rate
  # limit (5 starts / 10s), gives up, and leaves no panel at all. Disabling the
  # rate limit lets it keep restarting until the display settles. The known
  # offender (the native battery module aborting the bar) is replaced by a sysfs
  # poll script above, so this should now rarely fire.
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
          "custom/battery"
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
        "custom/battery" = {
          "exec" = "${batteryScript}";
          "return-type" = "json";
          "interval" = 30;
          # Also refreshes immediately when battery-charge-control toggles
          # the cap (it pkill-signals waybar with RTMIN+8).
          "signal" = 8;
          "hide-empty-text" = true;
          "tooltip" = false;
          "on-click" = "battery-charge-control toggle";
        };
        # Native battery module, trialed alongside custom/battery (which was
        # written to replace it: the native worker aborts with
        # "Could not watch events for .../BAT0" when its inotify races the
        # ucsi-source-psy supplies during PD negotiation — if the bar starts
        # flapping on display hotplug, remove this block again).
        "battery" = {
          "bat" = "BAT0";
          "interval" = 30;
          "states" = {
            "warning" = 25;
            "critical" = 10;
          };
          "format" = "{capacity}% {icon}";
          "format-charging" = "{capacity}% 󰂄";
          "format-plugged" = "{capacity}% 󰚥";
          "format-icons" = {
            "charging" = [ "󰢜" "󰂆" "󰂈" "󰂉" "󰂊" "󰂅" ];
            "default" = [ "󰁺" "󰁼" "󰁾" "󰂀" "󰂂" "󰁹" ];
          };
          "tooltip-format" = "{capacity}% · {power} W";
          # Click toggles the 80% charge cap (passwordless sudo rule for
          # battery-charge-control-write is in battery-manager.nix).
          "on-click" = "battery-charge-control toggle";
        };
        "temperature" = {
          # "thermal-zone" = 6;
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
      #custom-battery.capped {
        color: #a6e3a1;
      }
    '';
  };
}
