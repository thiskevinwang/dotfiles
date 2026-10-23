{
  description = "Kevin's macOS machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    oh-my-zsh = { url = "github:ohmyzsh/ohmyzsh"; flake = false; };
    zsh-autosuggestions = { url = "github:zsh-users/zsh-autosuggestions"; flake = false; };
    zsh-completions = { url = "github:zsh-users/zsh-completions"; flake = false; };
    tpm = { url = "github:tmux-plugins/tpm"; flake = false; };
    tmux-powerline = { url = "github:erikw/tmux-powerline"; flake = false; };
    vim-jsx = { url = "github:mxw/vim-jsx"; flake = false; };
    vim-simple-notifications = { url = "github:kristijanhusak/vim-simple-notifications"; flake = false; };
  };

  outputs = inputs@{ nixpkgs, nix-darwin, home-manager, ... }:
    let
      hosts = {
        kevin-mac = "aarch64-darwin";
        kevin-intel = "x86_64-darwin";
      };
      systems = nixpkgs.lib.mapAttrs (_: platform:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs; };
          modules = [
            ./nix/darwin.nix
            home-manager.darwinModules.home-manager
            {
              nixpkgs.hostPlatform = platform;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.kevin = import ./nix/home.nix;
            }
          ];
        }) hosts;
    in {
      darwinConfigurations = systems;

      # Bootstrap and Home Manager use the same file manifest.
      lib.bootstrap = nixpkgs.lib.mapAttrs (_: system:
        let
          cfg = system.config;
          home = cfg.home-manager.users.kevin;
        in {
          username = cfg.system.primaryUser;
          homeDirectory = home.home.homeDirectory;
          platform = cfg.nixpkgs.hostPlatform.system;
          repoLink = "${home.home.homeDirectory}/.local/share/dotfiles/repo";
          files = map (file: {
            target = file.target;
            source = "${file.source}";
          }) (builtins.filter (file: file.enable)
            (builtins.attrValues home.home.file));
        }) systems;
    };
}
