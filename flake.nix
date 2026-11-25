{
  description = "thiskevinwang's portable, reproducible dotfiles (macOS + Linux)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nix-darwin, ... }:
    let
      # Change this to match `whoami` on the target machine, or override
      # per-host below.
      defaultUser = "kevin";

      mkPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      mkPkgsUnstable = system: import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      # Shared home-manager configuration, parameterized by username/homeDirectory
      # so the same modules work on both macOS and Linux.
      mkHomeManagerModule = { username, homeDirectory, pkgsUnstable }: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = { inherit pkgsUnstable; };
        home-manager.users.${username} = import ./home {
          inherit username homeDirectory;
        };
      };
    in
    {
      # ------------------------------------------------------------------
      # macOS (nix-darwin) systems
      # ------------------------------------------------------------------
      darwinConfigurations = {
        # `darwin-rebuild switch --flake .#macbook`
        macbook = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./nix/darwin.nix
            home-manager.darwinModules.home-manager
            (mkHomeManagerModule {
              username = defaultUser;
              homeDirectory = "/Users/${defaultUser}";
              pkgsUnstable = mkPkgsUnstable "aarch64-darwin";
            })
          ];
        };
      };

      # ------------------------------------------------------------------
      # Linux (NixOS) systems
      # ------------------------------------------------------------------
      nixosConfigurations = {
        # `sudo nixos-rebuild switch --flake .#linux-desktop`
        linux-desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./nix/linux.nix
            home-manager.nixosModules.home-manager
            (mkHomeManagerModule {
              username = defaultUser;
              homeDirectory = "/home/${defaultUser}";
              pkgsUnstable = mkPkgsUnstable "x86_64-linux";
            })
          ];
        };
      };

      # ------------------------------------------------------------------
      # Standalone home-manager (no root / nix-darwin or NixOS required)
      # `home-manager switch --flake .#kevin@linux`
      # `home-manager switch --flake .#kevin@darwin`
      # ------------------------------------------------------------------
      homeConfigurations = {
        "${defaultUser}@linux" = home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs "x86_64-linux";
          extraSpecialArgs = { pkgsUnstable = mkPkgsUnstable "x86_64-linux"; };
          modules = [
            (import ./home {
              username = defaultUser;
              homeDirectory = "/home/${defaultUser}";
            })
          ];
        };

        "${defaultUser}@darwin" = home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs "aarch64-darwin";
          extraSpecialArgs = { pkgsUnstable = mkPkgsUnstable "aarch64-darwin"; };
          modules = [
            (import ./home {
              username = defaultUser;
              homeDirectory = "/Users/${defaultUser}";
            })
          ];
        };
      };
    };
}
