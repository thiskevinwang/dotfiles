{ username, homeDirectory }:
{ config, pkgs, lib, ... }:

{
  imports = [
    ./programs.nix
    ./shells.nix
    ./editors.nix
    ./terminal.nix
  ];

  home.username = username;
  home.homeDirectory = homeDirectory;

  # Bump this only when you have understood the changes it entails, see
  # https://nix-community.github.io/home-manager/release-notes.xhtml
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # `~/.gitignore` used by `git config --global core.excludesFile`.
  home.file.".gitignore".source = ../gitignore;

  # Base git config. Machine-specific overrides (e.g. GPG signing key) live
  # in `~/.gitconfig.local`, which is intentionally left unmanaged so it can
  # be created per-machine (see README.md).
  home.file.".gitconfig".source = ../gitconfig;
}
