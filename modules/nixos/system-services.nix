{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.tmp.cleanOnBoot = true;
  systemd.tmpfiles.rules = [
    "d /tmp/screenshots 1777 -"
  ];

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi = {
    enable = true; # runs the Avahi daemon
    nssmdns4 = true; # enables the mDNS NSS plug-in
    openFirewall = true; # opens the firewall for UDP port 5353
    settings.publish = {
      "disable-publishing" = false;
      "disable-user-service-publishing" = false;
      "publish-addresses" = true;
      "publish-domain" = true;
      "publish-hinfo" = true;
      "publish-workstation" = true;
    };
  };

  services.xserver = {
    enable = true;
    xkb.layout = "eu,ru";
    xkb.variant = ",";
    xkb.options = "grp:caps_switch,grp:lalt_lshift_toggle,lv3:ralt_switch,compose:lwin-altgr,compose:rctrl-altgr";
  };

  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
  };

  services.ollama.enable = false;
  services.pcscd.enable = true;
  services.fwupd.enable = true;
  services.logind.settings.Login.HandleLidSwitchDocked = "suspend-then-hibernate";

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "30m";
    SuspendState = "mem";
  };

  hardware.enableAllFirmware = true;
}
