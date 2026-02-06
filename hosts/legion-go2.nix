# Hardware configuration for Lenovo Legion Go 2
# This file will need to be updated with actual hardware details after installation

{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Kernel modules for Legion Go 2 specific hardware
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "amdgpu"  # AMD GPU support
  ];
  
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ 
    "kvm-amd"  # AMD-V support
    "amdgpu"   # AMD graphics driver
  ];
  boot.extraModulePackages = [ ];

  # Basic filesystem - will need to be adjusted for actual installation
  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/REPLACE_WITH_UUID";
  #   fsType = "ext4";
  # };

  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/REPLACE_WITH_EFI_UUID";
  #   fsType = "vfat";
  # };

  # Swap will be configured during installation
  swapDevices = [ ];

  # Networking setup
  networking.useDHCP = lib.mkDefault true;

  # Platform specifications
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  
  # Power management tuned for handheld device
  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";
  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.driSupport32Bit = true;
  
  # Enable AMD GPU acceleration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      amdvlk # Proprietary AMD Vulkan driver
      libva # Video acceleration
      libvdpau # Video decoding
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      amdvlk
    ];
  };
  
  # Handheld-specific hardware support
  hardware.xpadneo.enable = true; # Xbox controller support
  services.rtkit.enable = true; # Realtime audio support
  security.rtkit.enable = true;
}