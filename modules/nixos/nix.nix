{
  config,
  lib,
  pkgs,
  ...
}:

{
  nix = {
    # conflicts with determinate nix
    # package = pkgs.nixVersions.latest;
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "taranarmo" ];
      max-substitution-jobs = 30;
      download-buffer-size = 524288000;
      substituters = [
        "https://cache.nixos.org/?priority=1"
        "https://nix-community.cachix.org?priority=2"
        "https://hyprland.cachix.org?priority=2"
        "https://cache.flox.dev?priority=1"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
      ];
    };
    gc = {
      automatic = true;
      dates = "Thu";
      options = "--delete-older-than 30d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.nix-ld.enable = true;
}
