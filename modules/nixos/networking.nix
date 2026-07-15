{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.custom.networking = {
    wirelessInterface = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "wlo1";
      description = "The main wireless interface of the host, used for captive-browser.";
    };
  };

  config = {
    networking = {
      firewall = {
        enable = true;
        #package = pkgs.nftables;
        trustedInterfaces = [ "docker0" ];
        allowedTCPPorts = [
          22
          80
          443
        ]; # Enable ssh, http, https
        checkReversePath = false;
      };
      nat = {
        enable = true;
        internalInterfaces = [ "ve-+" ];
        externalInterface = "eth0";
      };
      nameservers = [
        "127.0.0.1"
        "::1"
        "1.1.1.1"
        "8.8.8.8"
      ];
      networkmanager = {
        enable = true;
        dns = "none";
        unmanaged = [ "interface-name:ve-*" ];
      };
    };

    services.dnscrypt-proxy = {
      enable = true;
      settings = {
        ipv6_servers = true;
        require_dnssec = true;

        sources.public-resolvers = {
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
          cache_file = "/var/lib/dnscrypt-proxy/public-resolvers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
        };
        # You can choose a specific set of servers from https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
        # server_names = [ ... ];
      };
    };

    systemd.services.dnscrypt-proxy.serviceConfig = {
      StateDirectory = "dnscrypt-proxy";
    };

    programs.captive-browser = lib.mkIf (config.custom.networking.wirelessInterface != null) {
      enable = true;
      interface = config.custom.networking.wirelessInterface;
    };
  };
}
