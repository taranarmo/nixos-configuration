{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Enable sound with pipewire.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  boot.kernelModules = [ "uvcvideo" ];

  environment.systemPackages = with pkgs; [
    libcamera
    v4l-utils
  ];

  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        FastConnectable = true;
      };
      GATT = {
        ReconnectIntervals = "1. 2. 3";
      };
      Policy = {
        ReconnectAttempts = 7;
      };
    };
  };
  services.blueman.enable = true;

  # MTP mount service
  services.gvfs.enable = true;
}
