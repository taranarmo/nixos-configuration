{
  description = "NixOS configuration with flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # home-manager related inputs
    home-manager = {
      #url = "github:nix-community/home-manager";
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    nurpkgs.url = "github:nix-community/NUR";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

#    nixpkgs-unfree = {
#      url = "github:numtide/nixpkgs-unfree";
#      inputs.nixpkgs.follows = "nixpkgs-unstable";
#    };

#    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
#    hyprland.url = "github:hyprwm/Hyprland";
#    hyprland-contrib = {
#      url = "github:hyprwm/contrib";
#      inputs.nixpkgs.follows = "hyprland/nixpkgs";
#    };
#    sops-nix = {
#      url = "github:Mic92/sops-nix";
#      inputs.nixpkgs.follows = "nixpkgs";
#      inputs.nixpkgs-stable.follows = "nixpkgs";
#    };
#    peerix = {
#      url = "github:cid-chan/peerix";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
#    impermanence.url = "github:nix-community/impermanence";
#
#    nixos-anywhere = {
#      url = "github:numtide/nixos-anywhere";
#      inputs = {
#        nixpkgs.follows = "nixpkgs";
#        disko.follows = "disko";
#      };
#    };

#    fenix = {
#      url = "github:nix-community/fenix";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
#
#    # Other project inputs
#    nvfetcher = {
#      url = "github:berberman/nvfetcher";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    home-manager,
    nur,
    ...
  }: {
    nixosConfigurations.nixos-ideapad = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      #specialArgs = { inherit inputs; };
      specialArgs.flake-inputs = inputs;
      modules = [
        ./configuration.nix
        nur.nixosModules.nur
        home-manager.nixosModules.home-manager
        {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.taranarmo = import ./home/home.nix;
        }
        ./cachix.nix
        #./firefox.nix
      ];
    };
  };
}
