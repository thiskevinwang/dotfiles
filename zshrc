# Initialize Homebrew without making shell startup depend on the terminal's
# current directory being readable. `brew shellenv` performs that check.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(cd "$HOME" && /opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(cd "$HOME" && /usr/local/bin/brew shellenv)"
fi

# Keep the externally installed Nix available after nix-darwin takes over zsh.
if ! (( $+commands[nix] )) && [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# Prefer the CLI tools selected by the locked Home Manager configuration.
export PATH="$HOME/.local/bin:$PATH"
if [[ -d "/etc/profiles/per-user/$USER/bin" ]]; then
  export PATH="/etc/profiles/per-user/$USER/bin:$PATH"
  fpath=("/etc/profiles/per-user/$USER/share/zsh/site-functions" $fpath)
fi

# Check for ARM or Intel arch
[[ $(uname -m) == "arm64" ]] && export IS_ARM=true || export IS_ARM=false

# Setup TTY for GPG
[[ -t 0 ]] && export GPG_TTY=$(tty)

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"

export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# Add wisely, as too many plugins slow down shell startup.
plugins=(
    fzf
    git
    zsh-autosuggestions
)
# Do not load zsh-completions as standard plugin
# https://github.com/zsh-users/zsh-completions?tab=readme-ov-file#oh-my-zsh
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

alias dm="dark-mode"

# Fix this error:
# complete:13: command not found: compdef
autoload -Uz compinit
compinit

# 1Password CLI completion (available after Homebrew initializes PATH).
if (( $+commands[op] )); then
  eval "$(op completion zsh)"
  compdef _op op
fi

# go-bindata
if (( $+commands[go] )); then
  export GOPATH=$(go env GOPATH)
  export PATH="$PATH:$GOPATH/bin"
fi

export AWS_PAGER=""


# Note this needs to come after plugins=(...)
# in order for plugins to load.
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# Pure prompt
autoload -U promptinit; promptinit
prompt pure

# Show when Proxyman has injected its proxy environment into this shell.
autoload -Uz add-zsh-hook
function _prompt_proxyman_status() {
    if [[ "$PROXYMAN_INJECTION_ACTIVE" == true ]]; then
        psvar[21]=proxyman
    else
        psvar[21]=''
    fi
}
add-zsh-hook precmd _prompt_proxyman_status
PROMPT='%(21V.%F{yellow}%21v%f .)'"$PROMPT"

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Sounds...
# # Turn off all beeps
# unsetopt BEEP
# Turn off autocomplete beeps
unsetopt LIST_BEEP

# Terraform
autoload -U +X bashcompinit && bashcompinit
alias tf=terraform

# TAB COMPLETIONS

## Terraform
if (( $+commands[terraform] )); then
  complete -o nospace -C "${commands[terraform]}" terraform
fi
## Nomad
if (( $+commands[nomad] )); then
  complete -o nospace -C "${commands[nomad]}" nomad
fi

# fnm
(( $+commands[fnm] )) && eval "$(fnm env --use-on-cd --shell zsh)"

# Python
# alias python=/usr/local/bin/python3
alias python=python3
alias pip='python3 -m pip'

# Ruby
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
# By default, binaries installed by gem will be placed into:
#   /opt/homebrew/lib/ruby/gems/3.1.0/bin
export PATH="${HOMEBREW_PREFIX:-/opt/homebrew}/lib/ruby/gems/3.1.0/bin:$PATH"
#
# You may want to add this to your PATH.
#
# ruby is keg-only, which means it was not symlinked into /opt/homebrew,
# because macOS already provides this software and installing another version in
# parallel can cause all kinds of trouble.
#
# If you need to have ruby first in your PATH, run:
export PATH="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/ruby/bin:$PATH"
#
# For compilers to find ruby you may need to set:
#   export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
#   export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"
#
# For pkg-config to find ruby you may need to set:
#   export PKG_CONFIG_PATH="/opt/homebrew/opt/ruby/lib/pkgconfig"


# Android
export ANDROID_SDK="$HOME/Library/Android/sdk"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# For cURL w/ HTTP3 support
# https://gist.github.com/xmlking/cff9510dac9281d29390392cbbb033a8
export PATH="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/curl/bin:$PATH"
export PATH="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/openjdk@17/bin:$PATH"
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# https://github.com/tobi/try
if [[ -f "$HOME/.local/try.rb" ]] && (( $+commands[ruby] )); then
  eval "$(ruby "$HOME/.local/try.rb" init "$HOME/src/tries")"
fi

# GPG TTY setup
[[ -t 0 ]] && export GPG_TTY=$(tty)

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# https://medium.com/@GroundControl/better-git-diffs-with-fzf-89083739a9cb
fd() {
  preview="git diff $@ -- {-1} | bat -n --color=always"
  git diff $@ --name-only | fzf -m --ansi --preview $preview
}

# Codex
cexec() { 
	codex --model=gpt-5.4 --yolo exec "$*";
}

(( $+commands[codex] )) && eval "$(codex completion zsh)"
