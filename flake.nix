{
  description = "NixOS configuration with flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    catppuccin.url = "github:catppuccin/nix";

    # home-manager related inputs
    home-manager = {
      #url = "github:nix-community/home-manager";
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix/release-24.11";

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
    catppuccin,
    nixvim,
    stylix,
    ...
  }: {
    nixosConfigurations.nixos-ideapad = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      #specialArgs = { inherit inputs; };
      specialArgs.flake-inputs = inputs;
      modules = [
        ./configuration.nix
        ./nixos-ideapad.nix
        nur.modules.nixos.default
        catppuccin.nixosModules.catppuccin
        home-manager.nixosModules.home-manager
        stylix.nixosModules.stylix
        {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hmbackup";
            home-manager.users.taranarmo = {
              imports = [
                ./home/home.nix
                catppuccin.homeManagerModules.catppuccin
                nixvim.homeManagerModules.nixvim
              ];
            };
        }
        ./cachix.nix
        #./firefox.nix
      ];
    };
  };
}
