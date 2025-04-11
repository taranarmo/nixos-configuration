{ lib, pkgs, ...}:

{
  # keyboard related
  hardware.keyboard.qmk.enable = true;
  environment.systemPackages = with pkgs; [
    via
    vial
  ];
  services.udev.packages = with pkgs; [
    via
    vial
    qmk-udev-rules
  ];
}
