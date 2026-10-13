{
  description = "NixOS configuration with flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    llm-agents.url = "github:numtide/llm-agents.nix";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim/";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    stylix.url = "github:nix-community/stylix/";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    # nurpkgs.url = "github:nix-community/NUR";

    disko.url = "github:nix-community/disko";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-contrib.url = "github:hyprwm/contrib";

    jovian-nixos.url = "github:Jovian-Experiments/Jovian-NixOS";

    nixpkgs-unfree = {
      url = "github:numtide/nixpkgs-unfree";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
      nixpkgs-small,
      llm-agents,
      nix-index-database,
      home-manager,
      # nur,
      catppuccin,
      nixvim,
      stylix,
      ...
    }:
    {
      nixosConfigurations.hp-omnibook = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          flake-inputs = inputs;
          inherit inputs;
          llm-pkgs = llm-agents.packages.x86_64-linux;
        };
        modules = [
          ./configuration.nix
          ./hosts/hp-omnibook.nix
          # nur.modules.nixos.default
          catppuccin.nixosModules.catppuccin
          home-manager.nixosModules.home-manager
          stylix.nixosModules.stylix
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hmbackup";
            home-manager.extraSpecialArgs = {
              inherit inputs;
              pkgs-small = import nixpkgs-small {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
              llm-pkgs = llm-agents.packages.x86_64-linux;
            };
            home-manager.users.taranarmo = {
              imports = [
                ./home/home.nix
                catppuccin.homeModules.catppuccin
                nixvim.homeModules.nixvim
                stylix.homeModules.stylix
                nix-index-database.homeModules.nix-index
              ];
            };
          }
          ./caches.nix
          ./hardware/keyboard.nix
          ./modules/nixos/gaming.nix
          { networking.hostName = "hp-omnibook"; }
          #./firefox.nix
        ];
      };

      nixosConfigurations.nixos-ideapad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          flake-inputs = inputs;
          inherit inputs;
          llm-pkgs = llm-agents.packages.x86_64-linux;
        };
        modules = [
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
              inherit inputs;
              pkgs-small = import nixpkgs-small {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
              llm-pkgs = llm-agents.packages.x86_64-linux;
            };
            home-manager.users.taranarmo = {
              imports = [
                ./home/home.nix
                catppuccin.homeModules.catppuccin
                nixvim.homeModules.nixvim
                stylix.homeModules.stylix
                nix-index-database.homeModules.nix-index
              ];
            };
          }
          ./caches.nix
          ./hardware/keyboard.nix
          { networking.hostName = "nixos-ideapad"; }
          #./firefox.nix
        ];
      };

      nixosConfigurations.hp-gaming = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          flake-inputs = inputs;
          inherit inputs;
          llm-pkgs = llm-agents.packages.x86_64-linux;
        };
        modules = [
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
              inherit inputs;
              pkgs-small = import nixpkgs-small {
                system = "x86_64-linux";
                config.allowUnfree = true;
              };
              llm-pkgs = llm-agents.packages.x86_64-linux;
            };
            home-manager.users.taranarmo = {
              imports = [
                ./home/home.nix
                catppuccin.homeModules.catppuccin
                nixvim.homeModules.nixvim
                stylix.homeModules.stylix
                nix-index-database.homeModules.nix-index
              ];
            };
          }
          ./caches.nix
          ./hardware/keyboard.nix
          ./modules/nixos/gaming.nix
          { networking.hostName = "hp-gaming"; }
        ];
      };
    };
}
