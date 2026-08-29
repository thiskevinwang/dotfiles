{ config, pkgs, lib, ... }:

{
  # NixOS release the system was first installed with. See
  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "24.11";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  # Minimal, machine-agnostic defaults. Hostname, bootloader, filesystems,
  # and hardware-specific settings should be added in a local, untracked
  # override (see README.md) or a machine-specific host module imported
  # here. The placeholders below only exist so this module evaluates
  # standalone (`nix flake check`); replace them with your real
  # `hardware-configuration.nix` before deploying to actual hardware.
  boot.loader.grub.devices = lib.mkDefault [ "/dev/sda" ];
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  networking.hostName = lib.mkDefault "nixos";

  time.timeZone = lib.mkDefault "America/New_York";

  users.users.kevin = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
}
