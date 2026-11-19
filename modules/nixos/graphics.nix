{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.custom.display = {
    scaling = lib.mkOption {
      type = lib.types.str;
      default = "1";
      description = "Default monitor scaling factor";
    };
    internalMonitor = lib.mkOption {
      type = lib.types.str;
      default = "eDP-1";
      description = "Identifier for the internal laptop monitor";
    };
    internalBitdepth = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "Color bit depth for the internal monitor (e.g. 10 for OLED)";
    };
  };

  config = {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver # VA-API (iHD) for Intel iGPUs (H.264, HEVC, VP9, AV1)
        vpl-gpu-rt # Intel VPL / QuickSync runtime
      ];
    };

    environment.systemPackages = with pkgs; [
      libva-utils # vainfo for verifying VA-API hardware acceleration
    ];
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    # xdg-desktop-portal works by exposing a series of D-Bus interfaces
    # known as portals under a well-known name
    # (org.freedesktop.portal.Desktop) and object path
    # (/org/freedesktop/portal/desktop).
    # The portal interfaces include APIs for file access, opening URIs,
    # printing and others.
    services.dbus.enable = true;
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        pkgs.xdg-desktop-portal-wlr
        pkgs.xdg-desktop-portal-gtk
      ];
    };
  };
}
