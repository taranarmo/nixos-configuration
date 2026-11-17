{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.custom.notebook;

  autoProfileScript = pkgs.writeShellScriptBin "auto-power-profile" ''
    set -euo pipefail

    detect_power() {
      # If any battery exists, check if any charger is online or battery is charging
      if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
        for ps in /sys/class/power_supply/*; do
          type=$(cat "$ps/type" 2>/dev/null || true)
          if [ "$type" = "Mains" ] || [ "$type" = "USB" ]; then
            online=$(cat "$ps/online" 2>/dev/null || echo 0)
            if [ "$online" = "1" ]; then
              echo "ac"
              return
            fi
          fi
        done

        # Fallback check on battery status
        for bat in /sys/class/power_supply/BAT*; do
          status=$(cat "$bat/status" 2>/dev/null || echo "Unknown")
          if [ "$status" != "Discharging" ] && [ "$status" != "Unknown" ]; then
            echo "ac"
            return
          fi
        done
        echo "battery"
      else
        # No battery present, treat as AC
        echo "ac"
      fi
    }

    apply_profile() {
      local profile="$1"
      local epp="$2"

      # 1. Update TuneD / PowerProfiles daemon via D-Bus if available
      if [ -S /run/dbus/system_bus_socket ]; then
        ${pkgs.systemd}/bin/busctl set-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile s "$profile" >/dev/null 2>&1 || true
      fi

      # 2. Write directly to sysfs platform_profile if writable (e.g. called from udev/root)
      if [ -w /sys/firmware/acpi/platform_profile ]; then
        choices=$(cat /sys/firmware/acpi/platform_profile_choices 2>/dev/null || true)
        if echo "$choices" | grep -qw "$profile"; then
          echo "$profile" > /sys/firmware/acpi/platform_profile 2>/dev/null || true
        fi
      fi

      # 3. Write CPU energy performance preference if writable
      if [ -n "$epp" ]; then
        for f in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
          if [ -w "$f" ]; then
            echo "$epp" > "$f" 2>/dev/null || true
          fi
        done
      fi
    }

    cmd="''${1:-apply}"

    case "$cmd" in
      apply)
        power=$(detect_power)
        if [ "$power" = "ac" ]; then
          apply_profile "${cfg.autoPowerProfile.acProfile}" "${cfg.autoPowerProfile.acEpp}"
          echo "Applied AC power profile: ${cfg.autoPowerProfile.acProfile} (EPP: ${cfg.autoPowerProfile.acEpp})"
        else
          apply_profile "${cfg.autoPowerProfile.batteryProfile}" "${cfg.autoPowerProfile.batteryEpp}"
          echo "Applied Battery power profile: ${cfg.autoPowerProfile.batteryProfile} (EPP: ${cfg.autoPowerProfile.batteryEpp})"
        fi
        ;;
      set)
        if [ "$#" -ne 2 ]; then
          echo "Usage: auto-power-profile set <profile>" >&2
          exit 1
        fi
        target="$2"
        epp=""
        if [ "$target" = "performance" ]; then
          epp="performance"
        elif [ "$target" = "power-saver" ] || [ "$target" = "quiet" ]; then
          epp="power"
        else
          epp="balance_performance"
        fi
        apply_profile "$target" "$epp"
        echo "Set power profile to $target (EPP: $epp)"
        ;;
      status)
        power=$(detect_power)
        echo "Power source: $([ "$power" = "ac" ] && echo "AC Power" || echo "Battery")"
        if [ -f /sys/firmware/acpi/platform_profile ]; then
          echo "Platform profile: $(cat /sys/firmware/acpi/platform_profile 2>/dev/null || echo "unknown")"
          echo "Available profiles: $(cat /sys/firmware/acpi/platform_profile_choices 2>/dev/null || echo "none")"
        fi
        if [ -f /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference ]; then
          echo "CPU EPP: $(cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference 2>/dev/null || echo "unknown")"
        fi
        if [ -S /run/dbus/system_bus_socket ]; then
          ppd_active=$(${pkgs.systemd}/bin/busctl get-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile 2>/dev/null | awk '{print $2}' | tr -d '"' || echo "unknown")
          echo "PowerProfiles daemon: $ppd_active"
        fi
        ;;
      *)
        echo "Usage: auto-power-profile [apply|status|set <profile>]" >&2
        exit 1
        ;;
    esac
  '';
in
{
  options.custom.notebook = {
    enable = mkEnableOption "notebook power-saving stack (TLP, thermald)";

    autoPowerProfile = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Automatically switch power and thermal profile on AC (performance) and battery (balanced)";
      };

      acProfile = mkOption {
        type = types.str;
        default = "performance";
        description = "ACPI/PPD power profile to use when connected to AC power";
      };

      batteryProfile = mkOption {
        type = types.str;
        default = "balanced";
        description = "ACPI/PPD power profile to use when running on battery";
      };

      acEpp = mkOption {
        type = types.str;
        default = "performance";
        description = "CPU Energy Performance Preference (EPP) when connected to AC power";
      };

      batteryEpp = mkOption {
        type = types.str;
        default = "balance_performance";
        description = "CPU Energy Performance Preference (EPP) when running on battery";
      };
    };
  };

  config = mkIf cfg.enable {
    services.tuned.enable = true;
    services.thermald.enable = true;

    environment.systemPackages = mkIf cfg.autoPowerProfile.enable [
      autoProfileScript
    ];

    # Udev rule: switch profile immediately on power supply online state change
    services.udev.extraRules = mkIf cfg.autoPowerProfile.enable ''
      SUBSYSTEM=="power_supply", ATTR{online}=="?*", RUN+="${autoProfileScript}/bin/auto-power-profile apply"
    '';

    # Systemd oneshot: apply profile on boot once daemons are up
    systemd.services.auto-power-profile = mkIf cfg.autoPowerProfile.enable {
      description = "Apply automatic power and thermal profile (AC vs Battery)";
      wantedBy = [ "multi-user.target" ];
      after = [
        "tuned.service"
        "tuned-ppd.service"
      ];
      wants = [ "tuned.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${autoProfileScript}/bin/auto-power-profile apply";
      };
    };

    # Re-assert profile on resume from suspend/hibernate
    systemd.services.auto-power-profile-resume = mkIf cfg.autoPowerProfile.enable {
      description = "Re-apply power profile after sleep";
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
        ExecStart = "${autoProfileScript}/bin/auto-power-profile apply";
      };
    };
  };
}
