{
  config,
  lib,
  pkgs,
  ...
}:

{
  virtualisation = {
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
      extraOptions = "--iptables=False";
      extraPackages = with pkgs; [
        docker-buildx
      ];
    };
    #podman = {
    #  enable = true;
    #  # Create a `docker` alias for podman, to use it as a drop-in replacement
    #  #dockerCompat = true;
    #  # Required for containers under podman-compose to be able to talk to each other.
    #  defaultNetwork.settings.dns_enabled = true;
    #  extraPackages = with pkgs; [
    #    podman-compose
    #  ];
    #};
    oci-containers = {
      backend = "podman";
    };
  };
}
