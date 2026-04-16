{
  description = "NixOS configuration with flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    catppuccin.url = "github:catppuccin/nix";

    home-manager.url = "github:nix-community/home-manager/";

    nixvim.url = "github:nix-community/nixvim/";

    stylix.url = "github:danth/stylix/";

    # nurpkgs.url = "github:nix-community/NUR";

    disko.url = "github:nix-community/disko";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-contrib.url = "github:hyprwm/contrib";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    jovian-nixos.url = "github:Jovian-Experiments/Jovian-NixOS";

    #    nixpkgs-unfree = {
    #      url = "github:numtide/nixpkgs-unfree";
    #    };

    #    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
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

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-master,
      home-manager,
      # nur,
      catppuccin,
      nixvim,
      stylix,
      determinate,
      ...
    }:
    {
      nixosConfigurations.hp = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.flake-inputs = inputs;
        modules = [
          determinate.nixosModules.default
          ./configuration.nix
          #./hosts/nixos-ideapad.nix
          # nur.modules.nixos.default
          catppuccin.nixosModules.catppuccin
          home-manager.nixosModules.home-manager
          stylix.nixosModules.stylix
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hmbackup";
            home-manager.extraSpecialArgs = {
              pkgs-master = import nixpkgs-master {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
            };
            home-manager.users.taranarmo = {
              imports = [
                ./home/home.nix
                catppuccin.homeModules.catppuccin
                nixvim.homeModules.nixvim
                stylix.homeModules.stylix
              ];
            };
          }
          ./cachix.nix
          ./hardware/keyboard.nix
          { networking.hostName = "nixos-ideapad"; }
          #./firefox.nix
        ];
      };

      nixosConfigurations.nixos-ideapad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.flake-inputs = inputs;
        modules = [
          determinate.nixosModules.default
          ./configuration.nix
          ./hosts/nixos-ideapad.nix
          # nur.modules.nixos.default
          catppuccin.nixosModules.catppuccin
          home-manager.nixosModules.home-manager
          stylix.nixosModules.stylix
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hmbackup";
            home-manager.extraSpecialArgs = {
              pkgs-master = import nixpkgs-master {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
            };
            home-manager.users.taranarmo = {
              imports = [
                ./home/home.nix
                catppuccin.homeModules.catppuccin
                nixvim.homeModules.nixvim
                stylix.homeModules.stylix
              ];
            };
          }
          ./cachix.nix
          ./hardware/keyboard.nix
          { networking.hostName = "nixos-ideapad"; }
          #./firefox.nix
        ];
      };

      nixosConfigurations.hp-gaming = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs.flake-inputs = inputs;
        modules = [
          determinate.nixosModules.default
          ./configuration.nix
          ./hosts/hp-gaming.nix
          # nur.modules.nixos.default
          catppuccin.nixosModules.catppuccin
          home-manager.nixosModules.home-manager
          stylix.nixosModules.stylix
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hmbackup";
            home-manager.extraSpecialArgs = {
              pkgs-master = import nixpkgs-master {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
            };
            home-manager.users.taranarmo = {
              imports = [
                ./home/home.nix
                catppuccin.homeModules.catppuccin
                nixvim.homeModules.nixvim
                stylix.homeModules.stylix
              ];
            };
          }
          ./cachix.nix
          ./hardware/keyboard.nix
          ./modules/nixos/gaming.nix
          { networking.hostName = "hp-gaming"; }
        ];
      };
    };
}
