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
      max-substitution-jobs = 100;
      download-buffer-size = 524288000;
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
