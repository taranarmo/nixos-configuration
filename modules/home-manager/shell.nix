{ config, pkgs, ... }:

{
  home.shellAliases = {
    qrclip = "echo $(clippaste) && clippaste | qrencode -t ansiutf8";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "colored-man-pages"
        "pass"
        "docker"
        "aws"
        "terraform"
        #"vi-mode"
      ];
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.pay-respects = {
    enable = true;
  };
}
