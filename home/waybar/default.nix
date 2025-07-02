{ pkgs, ... } :
{
  imports = [
    ./settings.nix
    ./style.nix
  ];
  home.packages = with pkgs; [
    font-awesome
  ];
  programs.waybar.enable = true;
}
