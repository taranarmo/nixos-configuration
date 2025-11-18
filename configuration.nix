{
  config,
  lib,
  pkgs,
  inputs,
  flake-inputs,
  ...
}:

{
  imports = [
    ./modules/nixos/base.nix
    ./modules/nixos/nix.nix
    ./modules/nixos/locale.nix
    ./modules/nixos/networking.nix
    ./modules/nixos/security.nix
    ./modules/nixos/shell.nix
    ./modules/nixos/git.nix
    ./modules/nixos/fonts.nix
    ./modules/nixos/virtualization.nix
    ./modules/nixos/users.nix
    ./modules/nixos/multimedia.nix
    ./modules/nixos/graphics.nix
    ./modules/nixos/system-services.nix
  ];
}
