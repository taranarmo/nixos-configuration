{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  nix = {
    package = pkgs.lixPackageSets.latest.lix;
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [ "taranarmo" ];
      max-substitution-jobs = 30;
    };
    registry = {
      nixpkgs-unfree.flake = inputs.nixpkgs-unfree;
      unfree.flake = inputs.nixpkgs-unfree;
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
  environment.localBinInPath = true;
}
