{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.custom.battery-manager;

  # Helper script that writes to sysfs. Runs as root.
  writeScript = pkgs.writeShellScriptBin "battery-charge-control-write" ''
    set -euo pipefail

    detect_interface() {
      if [ -f "/sys/class/power_supply/BAT0/charge_control_limit_max" ]; then
        echo "sysfs_limit"
      elif [ -f "/sys/class/power_supply/macsmc-battery/charge_control_limit_max" ]; then
        echo "apple_limit"
      elif [ -f "/sys/class/power_supply/BAT0/charge_control_end_threshold" ]; then
        echo "thinkpad_limit"
      elif [ -f "/sys/bus/platform/drivers/ideapad_laptop/VPC2004:00/conservation_mode" ]; then
        echo "ideapad"
      elif [ -f "/sys/devices/platform/ideapad/conservation_mode" ]; then
        echo "ideapad_alt"
      elif [ -f "/sys/devices/platform/lg-laptop/battery_care_limit" ]; then
        echo "lg"
      elif [ -f "/sys/devices/platform/samsung/battery_life_extender" ]; then
        echo "samsung"
      elif [ -f "/sys/class/power_supply/BAT0/charge_behaviour" ]; then
        echo "hp_behaviour"
      else
        echo "none"
      fi
    }

    interface=$(detect_interface)

    if [ "$interface" = "none" ]; then
      echo "Hardware battery threshold control not supported on this machine." >&2
      exit 1
    fi

    if [ "$#" -ne 1 ]; then
      echo "Usage: $0 <80|100>" >&2
      exit 1
    fi

    val="$1"
    if [ "$val" != "80" ] && [ "$val" != "100" ]; then
      echo "Invalid limit: $val. Must be 80 or 100." >&2
      exit 1
    fi

    case "$interface" in
      sysfs_limit)
        echo "$val" > /sys/class/power_supply/BAT0/charge_control_limit_max
        ;;
      apple_limit)
        echo "$val" > /sys/class/power_supply/macsmc-battery/charge_control_limit_max
        ;;
      thinkpad_limit)
        echo "$val" > /sys/class/power_supply/BAT0/charge_control_end_threshold
        ;;
      ideapad)
        if [ "$val" = "80" ]; then
          echo 1 > /sys/bus/platform/drivers/ideapad_laptop/VPC2004:00/conservation_mode
        else
          echo 0 > /sys/bus/platform/drivers/ideapad_laptop/VPC2004:00/conservation_mode
        fi
        ;;
      ideapad_alt)
        if [ "$val" = "80" ]; then
          echo 1 > /sys/devices/platform/ideapad/conservation_mode
        else
          echo 0 > /sys/devices/platform/ideapad/conservation_mode
        fi
        ;;
      lg)
        if [ "$val" = "80" ]; then
          echo 1 > /sys/devices/platform/lg-laptop/battery_care_limit
        else
          echo 0 > /sys/devices/platform/lg-laptop/battery_care_limit
        fi
        ;;
      samsung)
        if [ "$val" = "80" ]; then
          echo 1 > /sys/devices/platform/samsung/battery_life_extender
        else
          echo 0 > /sys/devices/platform/samsung/battery_life_extender
        fi
        ;;
      hp_behaviour)
        # HP firmware exposes charge modes (auto / inhibit-charge /
        # force-discharge), not % thresholds. Record the requested limit and
        # let battery-charge-hold.service enforce it with hysteresis; apply
        # immediately too for instant feedback.
        mkdir -p /var/lib/battery-charge-hold
        if [ "$val" = "80" ]; then
          echo 80 > /var/lib/battery-charge-hold/limit
          chmod 644 /var/lib/battery-charge-hold/limit
          # Make sure the hold daemon is enforcing (it may have been stopped
          # during manual testing).
          systemctl start --no-block battery-charge-hold.service >/dev/null 2>&1 || true
          cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 0)
          if [ "$cap" -ge 80 ]; then
            echo inhibit-charge > /sys/class/power_supply/BAT0/charge_behaviour 2>/dev/null || true
          fi
        else
          echo 100 > /var/lib/battery-charge-hold/limit
          chmod 644 /var/lib/battery-charge-hold/limit
          echo auto > /sys/class/power_supply/BAT0/charge_behaviour 2>/dev/null || true
        fi
        ;;
    esac

    echo "Successfully set battery limit to $val%"
  '';

  # User-facing script. Interacts with the write helper and formats Waybar JSON.
  cliScript = pkgs.writeShellScriptBin "battery-charge-control" ''
    set -euo pipefail

    detect_interface() {
      if [ -f "/sys/class/power_supply/BAT0/charge_control_limit_max" ]; then
        echo "sysfs_limit"
      elif [ -f "/sys/class/power_supply/macsmc-battery/charge_control_limit_max" ]; then
        echo "apple_limit"
      elif [ -f "/sys/class/power_supply/BAT0/charge_control_end_threshold" ]; then
        echo "thinkpad_limit"
      elif [ -f "/sys/bus/platform/drivers/ideapad_laptop/VPC2004:00/conservation_mode" ]; then
        echo "ideapad"
      elif [ -f "/sys/devices/platform/ideapad/conservation_mode" ]; then
        echo "ideapad_alt"
      elif [ -f "/sys/devices/platform/lg-laptop/battery_care_limit" ]; then
        echo "lg"
      elif [ -f "/sys/devices/platform/samsung/battery_life_extender" ]; then
        echo "samsung"
      elif [ -f "/sys/class/power_supply/BAT0/charge_behaviour" ]; then
        echo "hp_behaviour"
      else
        echo "none"
      fi
    }

    get_limit() {
      interface=$(detect_interface)
      case "$interface" in
        sysfs_limit)
          cat /sys/class/power_supply/BAT0/charge_control_limit_max
          ;;
        apple_limit)
          cat /sys/class/power_supply/macsmc-battery/charge_control_limit_max
          ;;
        thinkpad_limit)
          cat /sys/class/power_supply/BAT0/charge_control_end_threshold
          ;;
        ideapad)
          val=$(cat /sys/bus/platform/drivers/ideapad_laptop/VPC2004:00/conservation_mode)
          [ "$val" = "1" ] && echo "80" || echo "100"
          ;;
        ideapad_alt)
          val=$(cat /sys/devices/platform/ideapad/conservation_mode)
          [ "$val" = "1" ] && echo "80" || echo "100"
          ;;
        lg)
          val=$(cat /sys/devices/platform/lg-laptop/battery_care_limit)
          [ "$val" = "1" ] && echo "80" || echo "100"
          ;;
        samsung)
          val=$(cat /sys/devices/platform/samsung/battery_life_extender)
          [ "$val" = "1" ] && echo "80" || echo "100"
          ;;
        hp_behaviour)
          # The persisted limit is the truth; the firmware mode legitimately
          # flips to auto inside the hysteresis band or while unplugged,
          # which used to display as a reset limit (even charging "100").
          f=/var/lib/battery-charge-hold/limit
          if [ -r "$f" ]; then
            v=$(cat "$f" 2>/dev/null || echo 100)
            [ "$v" = "80" ] && echo "80" || echo "100"
          else
            cur=$(grep -o '\[[a-z-]*\]' /sys/class/power_supply/BAT0/charge_behaviour | tr -d '[]')
            [ "$cur" = "inhibit-charge" ] && echo "80" || echo "100"
          fi
          ;;
        none)
          echo "none"
          ;;
      esac
    }

    cmd="''${1:-status}"

    case "$cmd" in
      get)
        get_limit
        ;;
      set)
        if [ "$#" -ne 2 ]; then
          echo "Usage: $0 set <80|100>" >&2
          exit 1
        fi
        sudo /run/current-system/sw/bin/battery-charge-control-write "$2"
        ;;
      toggle)
        curr=$(get_limit)
        if [ "$curr" = "none" ]; then
          # For unsupported hardware, toggle our soft limit file
          limit_file="$HOME/.config/battery-soft-limit"
          if [ -f "$limit_file" ]; then
            rm -f "$limit_file"
            ${pkgs.libnotify}/bin/notify-send -t 3000 "Battery Manager" "Soft charge limit disabled. Charging to 100%."
          else
            echo "80" > "$limit_file"
            ${pkgs.libnotify}/bin/notify-send -t 3000 "Battery Manager" "Soft charge limit enabled at 80%."
          fi
        else
          if [ "$curr" = "100" ]; then
            sudo /run/current-system/sw/bin/battery-charge-control-write "80"
            ${pkgs.libnotify}/bin/notify-send -t 3000 "Battery Manager" "Hardware charge limit set to 80%."
          else
            sudo /run/current-system/sw/bin/battery-charge-control-write "100"
            ${pkgs.libnotify}/bin/notify-send -t 3000 "Battery Manager" "Hardware charge limit set to 100% (Full)."
          fi
        fi
        pkill -RTMIN+8 waybar || true
        ;;
      status)
        bat="/sys/class/power_supply/BAT0"
        if [ ! -d "$bat" ]; then
          exit 0
        fi
        cap=$(cat "$bat/capacity" 2>/dev/null || echo "0")
        status=$(cat "$bat/status" 2>/dev/null || echo "Unknown")
        
        limit=$(get_limit)
        is_soft=false
        if [ "$limit" = "none" ]; then
          if [ -f "$HOME/.config/battery-soft-limit" ]; then
            limit="80"
            is_soft=true
          fi
        fi

        # Choose battery icon
        icons=(󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)
        idx=$(( (cap + 5) / 10 ))
        [ "$idx" -gt 10 ] && idx=10
        icon="''${icons[$idx]}"

        # Charging symbols
        charge_icon=""
        if [ "$status" = "Charging" ]; then
          charge_icon="⚡"
        elif [ "$status" = "Full" ]; then
          charge_icon="🔌"
        fi

        # Format display text and class
        if [ "$limit" = "80" ]; then
          if [ "$is_soft" = "true" ]; then
            text="$cap% $icon$charge_icon (soft 80% cap)"
            tooltip="Battery: $cap%\nStatus: $status\nSoft Limit: 80%\nClick to toggle (charge to 100%)"
            class="soft-capped"
          else
            text="$cap% $icon$charge_icon (80% cap)"
            tooltip="Battery: $cap%\nStatus: $status\nHardware Limit: 80%\nClick to toggle (charge to 100%)"
            class="capped"
          fi
        else
          text="$cap% $icon$charge_icon"
          tooltip="Battery: $cap%\nStatus: $status\nLimit: None (100%)\nClick to toggle (limit to 80%)"
          class="normal"
        fi

        if [ "$cap" -le 10 ]; then
          class="critical"
        elif [ "$cap" -le 25 ]; then
          class="warning"
        fi
        [ "$status" = "Charging" ] && [ "$class" = "normal" ] && class="charging"

        # Escape quotes in tooltip
        tooltip=$(echo "$tooltip" | sed 's/"/\\"/g')
        printf '{"text":"%s","class":"%s","percentage":%s,"tooltip":"%s"}\n' "$text" "$class" "$cap" "$tooltip"
        ;;
      *)
        echo "Usage: $0 {get|set <80|100>|toggle|status}" >&2
        exit 1
        ;;
    esac
  '';
in
{
  options.custom.battery-manager = {
    enable = mkEnableOption "custom battery charge manager";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      cliScript
      writeScript
    ];

    # Add passwordless sudo rule for the write helper script
    security.sudo.extraRules = [
      {
        users = [ "taranarmo" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/battery-charge-control-write";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    # Re-arm battery charge hold immediately when an AC or USB-PD charger is plugged in or renegotiates.
    # Note: We write directly to sysfs rather than restarting the daemon service, preventing
    # rapid-fire udev bursts across multiple power supplies from tripping systemd's StartLimitBurst.
    services.udev.extraRules = let
      udevInhibitScript = pkgs.writeShellScript "udev-battery-charge-inhibit" ''
        if [ "$(${pkgs.coreutils}/bin/cat /var/lib/battery-charge-hold/limit 2>/dev/null)" = "80" ]; then
          cb=/sys/class/power_supply/BAT0/charge_behaviour
          cap=$(${pkgs.coreutils}/bin/cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 0)
          if [ "$cap" -ge 80 ] && [ -w "$cb" ]; then
            echo inhibit-charge > "$cb" 2>/dev/null || true
          fi
        fi
      '';
    in ''
      SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${udevInhibitScript}"
    '';

    # Software limit notifier service (systemd user daemon)
    systemd.user.services.battery-soft-limit = {
      description = "Software battery charge limit notification daemon";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.writeShellScript "battery-soft-limit-daemon" ''
          set -eu
          notified=false

          # Hardware charge control (e.g. hp-wmi charge_behaviour) supersedes
          # the soft-limit notifier.
          if [ -f /sys/class/power_supply/BAT0/charge_behaviour ]; then
            exit 0
          fi

          while true; do
            if [ -f "$HOME/.config/battery-soft-limit" ] && [ -d "/sys/class/power_supply/BAT0" ]; then
              limit=$(cat "$HOME/.config/battery-soft-limit" 2>/dev/null || echo "80")
              limit=$(echo "$limit" | tr -cd '0-9')
              if [ -z "$limit" ]; then limit=80; fi
              
              cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "0")
              status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")
              
              if [ "$status" = "Charging" ] && [ "$cap" -ge "$limit" ]; then
                if [ "$notified" = "false" ]; then
                  ${pkgs.libnotify}/bin/notify-send \
                    -u critical \
                    -a "Battery Manager" \
                    "🔋 Battery at $cap%" \
                    "Reached soft charge threshold ($limit%). Please unplug charger to protect battery health."
                  notified=true
                fi
              elif [ "$status" != "Charging" ] || [ "$cap" -lt "$((limit - 2))" ]; then
                notified=false
              fi
            else
              notified=false
            fi
            sleep 15
          done
        ''}";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    # Hardware charge-hold daemon for mode-based interfaces (HP
    # charge_behaviour): inhibits charging at 80% and resumes at 75% while
    # plugged in. Exits immediately on hardware with direct thresholds, where
    # the write helper alone is sufficient.
    systemd.services.battery-charge-hold = {
      description = "Battery charge hold daemon (mode-based charge_behaviour)";
      wantedBy = [ "multi-user.target" ];
      unitConfig = {
        # Never fail permanently from rate-limiting on rapid resume/udev triggers
        StartLimitIntervalSec = 0;
      };
      serviceConfig = {
        Type = "simple";
        StateDirectory = "battery-charge-hold";
        StateDirectoryMode = "755";
        ExecStart = "${pkgs.writeShellScript "battery-charge-hold-daemon" ''
          bat=/sys/class/power_supply/BAT0
          cb="$bat/charge_behaviour"
          # The battery may register after multi-user (hp-wmi seeds the
          # power_supply extension after a firmware read), so wait briefly
          # instead of exiting 0 and leaving the limit unenforced until the
          # next boot.
          i=0
          while [ ! -f "$cb" ] && [ "$i" -lt 24 ]; do
            sleep 5
            i=$((i + 1))
          done
          [ -f "$cb" ] || exit 0

          limit_file=/var/lib/battery-charge-hold/limit
          # While the limit is disabled the daemon never touches
          # charge_behaviour (except the one-shot auto restore below), so
          # manual writes are not fought.
          first=1
          last_limit=""
          last_status=""
          while :; do
            limit=$(cat "$limit_file" 2>/dev/null || echo 100)
            if [ "$limit" = "80" ]; then
              cap=$(cat "$bat/capacity" 2>/dev/null || echo 0)
              status=$(cat "$bat/status" 2>/dev/null || echo Unknown)
              cur=$(grep -o '\[[a-z-]*\]' "$cb" 2>/dev/null | tr -d '[]')
              if [ -z "$cur" ]; then
                cur=auto
              fi

              # Only intervene while on AC (anything but "Discharging").
              target=""
              if [ "$status" != "Discharging" ]; then
                if [ "$cap" -ge 80 ]; then
                  target=inhibit-charge
                elif [ "$cap" -le 75 ]; then
                  target=auto
                elif [ "$status" = "Charging" ] && [ "$cur" = "inhibit-charge" ]; then
                  # The EC autonomously reset to active charging on charger plug; sync sysfs so it reflects auto charging up to 80%
                  target=auto
                fi
              fi

              if [ -n "$target" ]; then
                # On the first iteration after every (re)start (boot,
                # nixos-rebuild switch, resume hook, udev charger event),
                # or if the mode changed, or if AC status transitioned,
                # or if target is inhibit-charge but hardware is actively Charging
                # (stale sysfs cache bypassed by firmware/EC on charger swap),
                # write unconditionally.
                if [ "$first" = 1 ] || [ "$cur" != "$target" ] || [ "$status" != "$last_status" ] || { [ "$target" = "inhibit-charge" ] && [ "$status" = "Charging" ]; }; then
                  echo "$target" > "$cb" 2>/dev/null || true
                  cur=$target
                fi
              fi
              last_status=$status
            elif [ "$first" = 1 ] || [ "$last_limit" = "80" ]; then
              echo auto > "$cb" 2>/dev/null || true
            fi
            first=0
            last_limit=$limit

            # Poll faster (5s) when actively charging near/above the limit to catch transitions quickly
            if [ "$limit" = "80" ] && [ "$status" = "Charging" ]; then
              sleep 5
            else
              sleep 30
            fi
          done
        ''}";
        Restart = "on-failure";
        RestartSec = "10s";
      };
    };

    # The firmware may drop the charge mode across suspend/hibernate while
    # the kernel-side cache persists, which drops below the daemon's
    # stale-value radar. Re-running the daemon re-asserts the mode
    # unconditionally on its first iteration, immediately after wake.
    systemd.services."battery-charge-hold-resume" = {
      description = "Re-arm battery charge hold after system sleep";
      wantedBy = [
        "suspend.target"
        "hibernate.target"
        "hybrid-sleep.target"
        "suspend-then-hibernate.target"
      ];
      after = [
        "suspend.target"
        "hibernate.target"
        "hybrid-sleep.target"
        "suspend-then-hibernate.target"
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.systemd}/bin/systemctl --no-block restart battery-charge-hold.service";
      };
    };

    # While the system is asleep the daemon is not running, so firmware left
    # in "auto" charges an unplugged-then-later-plugged laptop straight to
    # 100%. Inhibit charging just before sleep (harmless while on battery,
    # and the firmware retains the mode), making plugging in during sleep a
    # no-op; the resume hook above re-asserts the hysteresis after wake.
    systemd.services.battery-charge-hold-sleep = {
      description = "Inhibit battery charging before system sleep";
      wantedBy = [ "sleep.target" ];
      before = [ "sleep.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "battery-charge-hold-sleep" ''
          limit=$(cat /var/lib/battery-charge-hold/limit 2>/dev/null)
          [ "$limit" = "80" ] || exit 0
          cb=/sys/class/power_supply/BAT0/charge_behaviour
          [ -f "$cb" ] || exit 0
          echo inhibit-charge > "$cb" 2>/dev/null || true
        ''}";
      };
    };
  };
}
