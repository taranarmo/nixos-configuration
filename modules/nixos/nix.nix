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
  };

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 4d --keep 3";
    };
    flake = "/home/taranarmo/nixos-configuration";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.nix-ld.enable = true;
  environment.localBinInPath = true;
}
