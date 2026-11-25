{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "fzf" "git" ];
    };

    plugins = [
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
      }
    ];

    initExtra = ''
      # Check for ARM or Intel arch
      [[ $(uname -m) == "arm64" ]] && export IS_ARM=true || export IS_ARM=false

      # Setup TTY for GPG
      export GPG_TTY=$(tty)

      export USE_GKE_GCLOUD_AUTH_PLUGIN=True
      export AWS_PAGER=""

      # 1Password CLI completion, if installed.
      if (( $+commands[op] )); then
        eval "$(op completion zsh)"
        compdef _op op
      fi

      # fnm (Node version manager)
      if (( $+commands[fnm] )); then
        eval "$(fnm env --use-on-cd --shell zsh)"
      fi

      # Turn off autocomplete beeps.
      unsetopt LIST_BEEP

      # Pure prompt: https://github.com/sindresorhus/pure
      fpath+=(${config.home.homeDirectory}/.zsh/pure)
      autoload -U promptinit; promptinit
      prompt pure
    '';
  };

  # Pure prompt: https://github.com/sindresorhus/pure
  # Populated at `~/.zsh/pure` by the `home.file` entry below; the fpath
  # here just points zsh at that same path.
  home.file.".zsh/pure" = {
    source = pkgs.fetchFromGitHub {
      owner = "sindresorhus";
      repo = "pure";
      rev = "v1.21.2";
      hash = "sha256-3n0iu1MB+ekTsSyeUKsMBS+wjapg5nvOm8f0iZjIYjc=";
    };
    recursive = true;
  };
}
