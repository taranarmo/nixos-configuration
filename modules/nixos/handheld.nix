{ config, lib, pkgs, ... }:

{
  # Handheld-specific packages and services for gaming
  environment.systemPackages = with pkgs; [
    # Game launchers for handheld experience
    bottles # For running Windows games
    heroic # GOG and Epic Games launcher
    prismlauncher # Minecraft launcher

    # Handheld gaming utilities
    goverlay # Steam overlay for non-Steam games
    gamescope # Compositor for games with lower latency

    # Input and control utilities
    joycond # Joy-con daemon
  ];

  # Enable power management tuned for handheld device
  services.power-profiles-daemon.enable = true; # Power profile switching
  services.upower.enable = true; # Power management service


  # Configure for handheld gaming usage patterns
  services.logind = {
    settings.Login = {
      HandleLidSwitch = lib.mkForce "ignore"; # Prevent sleep when using handheld
      HandleLidSwitchDocked = lib.mkForce "ignore";
      HandleLidSwitchExternalPower = lib.mkForce "ignore";
      HandlePowerKey = lib.mkForce "hibernate";
    };
  };

  # Enable overclocking support for gaming performance
  hardware.cpu.amd.updateMicrocode = lib.mkDefault true;

  # Enable controller support for handheld
  hardware.xone.enable = true; # Xbox One controller support

  # System tuning for handheld gaming
  boot.extraModprobeConfig = ''
    # Reduce input latency
    options usbhid mousepoll=1
  '';

  # Enable additional kernel parameters for gaming performance
  boot.kernelParams = [
    # General performance
    "elevator=none" # Use default scheduler
    "nowatchdog" # Disabled watchdog for performance
  ];
}