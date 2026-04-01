{ config, pkgs, pkgs-master, lib, ... }:

{
  imports = [
    ./qwen.nix
    ./google.nix
  ];

  programs.opencode = {
    enable = true;
    package = pkgs-master.opencode;
  };
}
