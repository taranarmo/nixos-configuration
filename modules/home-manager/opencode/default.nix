{ config, pkgs, pkgs-master, lib, ... }:

{
  imports = [
    ./google.nix
  ];

  programs.opencode = {
    enable = true;
    package = pkgs-master.opencode;
  };
}
