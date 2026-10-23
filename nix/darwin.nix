{ lib, ... }:
{
  system.primaryUser = "kevin";
  users.users.kevin.home = "/Users/kevin";
  system.stateVersion = 7;
  nixpkgs.config.allowUnfreePredicate = package:
    builtins.elem (lib.getName package) [ "typescript-vim" ];

  # Keep the existing installer, daemon, and Nix version under their owner.
  nix.enable = false;

  homebrew = {
    enable = true;
    extraConfig = builtins.readFile ../Brewfile;
    onActivation = {
      cleanup = "none";
      autoUpdate = false;
      upgrade = false;
    };
  };

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToControl = true;
}
