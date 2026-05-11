{
  config,
  lib,
  pkgs,
  ...
}:

{
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
      dispatcherScripts = [
        {
          source = pkgs.writeShellScript "captive-portal-dns" ''
            action="$2"

            [ "$action" = "connectivity-change" ] || exit 0

            backup=/run/captive-portal-resolv.conf.bak

            get_dhcp_dns() {
              for iface in $(${pkgs.networkmanager}/bin/nmcli -t -f DEVICE,STATE device \
                             | ${pkgs.gnugrep}/bin/grep ':connected$' \
                             | ${pkgs.coreutils}/bin/cut -d: -f1); do
                ${pkgs.networkmanager}/bin/nmcli -t -f IP4.DNS device show "$iface" 2>/dev/null \
                  | ${pkgs.gnused}/bin/sed -n 's/^IP4\.DNS\[[0-9]*\]://p'
              done
            }

            log() {
              ${pkgs.util-linux}/bin/logger -t captive-portal-dns "$@"
            }

            case "$CONNECTIVITY_STATE" in
              PORTAL|LIMITED)
                [ -f "$backup" ] && exit 0
                dns_servers=$(get_dhcp_dns)
                [ -z "$dns_servers" ] && exit 0
                cp /etc/resolv.conf "$backup"
                ${pkgs.systemd}/bin/systemctl stop dnscrypt-proxy2.service || true
                {
                  for ns in $dns_servers; do
                    echo "nameserver $ns"
                  done
                } > /etc/resolv.conf
                log "captive portal detected, switched to DHCP DNS: $(echo $dns_servers | tr '\n' ' ')"
                ;;
              FULL)
                [ -f "$backup" ] || exit 0
                mv "$backup" /etc/resolv.conf
                ${pkgs.systemd}/bin/systemctl start dnscrypt-proxy2.service || true
                log "full connectivity, restored encrypted DNS"
                ;;
            esac
          '';
        }
      ];
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
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
      # You can choose a specific set of servers from https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
      # server_names = [ ... ];
    };
  };

  systemd.services.dnscrypt-proxy2.serviceConfig = {
    StateDirectory = "dnscrypt-proxy";
  };
}
