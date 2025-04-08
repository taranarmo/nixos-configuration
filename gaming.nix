{ pkgs, ... }:
 
{
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    extest.enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    extraPackages = with pkgs; [
      mangohud
      protonup
    ];
  };
  programs.gamemode.enable = true;
 
  environment.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
  };

  hardware.steam-hardware.enable = true;
}
