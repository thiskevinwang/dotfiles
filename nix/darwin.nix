{ config, pkgs, lib, ... }:

{
  # Used for backwards compatibility, please read the changelog before
  # changing: `darwin-help changelog`
  system.stateVersion = 5;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  # Let nix-darwin manage the `nix` package/daemon itself.
  nix.enable = true;

  environment.shells = [ pkgs.zsh ];
  programs.zsh.enable = true;

  # Map Caps Lock -> Control, see README.md#misc-machine-setup
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;

  system.defaults.dock.autohide = lib.mkDefault true;
  system.defaults.finder.AppleShowAllExtensions = lib.mkDefault true;

  security.pam.enableSudoTouchIdAuth = true;
}
