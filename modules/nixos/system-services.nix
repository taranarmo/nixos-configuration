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
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      hinfo = true;
      userServices = true;
      workstation = true;
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

  services.ollama.enable = true;
  services.pcscd.enable = true;
  services.fwupd.enable = true;
  services.logind.settings.Login.HandleLidSwitchDocked = "suspend-then-hibernate";

  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30m
    SuspendState=mem
  '';

  hardware.enableAllFirmware = true;
}
