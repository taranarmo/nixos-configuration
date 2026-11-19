{
  config,
  lib,
  pkgs,
  ...
}:

{
  users = {
    users.taranarmo = {
      isNormalUser = true;
      description = "Sergey Volkov";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      packages = with pkgs; [
        lynx
        mpd
        mpc
        gimp3
        taskwarrior3
        telegram-desktop
        apvlv
        libnotify
        aspell
        aspellDicts.en
        aspellDicts.de
        aspellDicts.ru
        ausweisapp
        hurl
      ];
    };
  };
}
