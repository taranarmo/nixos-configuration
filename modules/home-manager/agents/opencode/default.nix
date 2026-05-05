{ config, pkgs, pkgs-small, lib, ... }:

{
  imports = [
    ./google.nix
  ];

  programs.opencode = {
    enable = true;
    package = pkgs.opencode;
  };
}
