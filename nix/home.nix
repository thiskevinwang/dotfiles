{ config, pkgs, inputs, ... }:
{
  imports = [ ./editors.nix ];

  home.username = "kevin";
  home.homeDirectory = "/Users/kevin";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    awscli2 bat bottom certigo cfssl cmake doggo fd fnm fzf gh git git-lfs
    gnupg go goreleaser jq lsd jwt-cli mercurial fastfetch neovim nodejs
    nushell pinentry_mac pure-prompt ripgrep tree uv watch watchman
    libwebp yq-go tmux rtk python3 ibm-plex codex mas
  ];

  fonts.fontconfig.enable = true;

  home.file = {
    ".zshrc".text = ''
      export ZSH=${inputs.oh-my-zsh}
      export ZSH_CUSTOM="$HOME/.local/share/dotfiles/zsh-custom"
      source "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
      source ${../zshrc}
    '';
    ".local/share/dotfiles/zsh-custom/plugins/zsh-autosuggestions".source = inputs.zsh-autosuggestions;
    ".local/share/dotfiles/zsh-custom/plugins/zsh-completions".source = inputs.zsh-completions;
    ".gitconfig".text = builtins.replaceStrings
      [ "program = gpg" "!gh auth git-credential" ]
      [ "program = ${pkgs.gnupg}/bin/gpg" "!${pkgs.gh}/bin/gh auth git-credential" ]
      (builtins.readFile ../gitconfig);
    ".gitignore".source = ../gitignore;
    ".tmux.conf".source = ../tmux.conf;
    ".tmux/plugins/tpm".source = inputs.tpm;
    ".tmux/plugins/tmux-powerline".source = inputs.tmux-powerline;
    ".config/tmux-powerline/config.sh".source = ../tmux-powerline/config.sh;
    ".config/tmux-powerline/themes/theme.sh".source = ../tmux-powerline/theme.sh;
    ".config/ghostty/config".source = ../ghostty/config;
    "Library/Application Support/nushell/config.nu".source = ../nushell/config.nu;
    ".codex/AGENTS.md".source = ../AGENTS.md;
    ".codex/RTK.md".source = ../RTK.md;
    ".claude/CLAUDE.md".source = ../AGENTS.md;
    ".config/zed/AGENTS.md".source = ../AGENTS.md;
    # Zed settings remain writable through the checkout selected by bootstrap.
    ".config/zed/settings.json".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.local/share/dotfiles/repo/zed/settings.json";
  };
}
