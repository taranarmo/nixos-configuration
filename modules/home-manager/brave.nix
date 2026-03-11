{
  config,
  lib,
  pkgs,
  flake-inputs,
  inputs,
  ...
}:
{
  programs.brave = {
    enable = true;
  };
}
