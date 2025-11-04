{ config, pkgs, ... }:

{
  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user.name = "Sergey Volkov ";
      user.email = "taranarmo@gmail.com";
    };
  };
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-tty;
  };
}