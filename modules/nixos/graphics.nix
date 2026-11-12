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
    };
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
