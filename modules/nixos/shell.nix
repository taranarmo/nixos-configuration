{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Default shell for users
  users = {
    defaultUserShell = pkgs.zsh;
  };

  programs.zsh = {
    enable = true;
  };

  services.atd.enable = true;
}
