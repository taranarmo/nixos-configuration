{ config, lib, pkgs, ... }:

{
  users = {
    users.taranarmo = {
      isNormalUser = true;
      description = "Sergey Volkov";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [
        firefox-esr
        qutebrowser
        lynx
        mpd
        mpc
        gimp3
        taskwarrior3
        telegram-desktop
        apvlv
        libnotify
        mpv
        aspell
        aspellDicts.en
        aspellDicts.de
        aspellDicts.ru
        ausweisapp
        htop-vim
        hurl
      ];
    };
  };
}