{ config, pkgs, lib, pkgsUnstable ? pkgs, ... }:

# Common CLI tools, mirroring the binaries previously installed via
# `Brewfile`. GUI-only casks (1Password, Docker Desktop, Discord, etc.) are
# not managed here since they don't have good cross-platform Nix support;
# install those manually per-machine.
{
  home.packages = with pkgs; [
    awscli2
    bat # better cat
    bottom # better top
    cfssl
    cmake
    dogdns # `dog`, better dig
    fnm # Node version manager
    fzf
    gh # GitHub CLI
    gnupg
    go
    goreleaser
    jq
    lsd # better ls https://github.com/lsd-rs/lsd
    neofetch
    nushell # `nu`
    postgresql # psql
    ripgrep # `rg`, better grep
    tree
    uv # python dependency manager
    watch
    watchman
    libwebp
    yq-go # jq, but for YAML
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    pinentry_mac
  ];
}
