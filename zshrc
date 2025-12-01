# Ensure brew can be found
# Issue seen on m1 max mbp
[[ -f /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)

# Check for ARM or Intel arch
[[ $(uname -m) == "arm64" ]] && export IS_ARM=true || export IS_ARM=false

# Setup TTY for GPG
export GPG_TTY=$(tty)

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/kevin/.oh-my-zsh"

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

# 1password
eval "$(op completion zsh)"; compdef _op op

# OpenAI
[[ -f "$HOME/.openai/credentials" ]] && . "$HOME/.openai/credentials"

# ensure brew is in path
export PATH=/opt/homebrew/bin:$PATH


# go-bindata
export PATH=$PATH:$(go env GOPATH)/bin
# GOPATH
export GOPATH=$(go env GOPATH)

export AWS_PAGER=""


# Note this needs to come after plugins=(...)
# in order for plugins to load.
source $ZSH/oh-my-zsh.sh

# Pure prompt
autoload -U promptinit; promptinit
prompt pure

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
complete -o nospace -C /opt/homebrew/bin/terraform terraform
## Nomad
complete -o nospace -C /opt/homebrew/bin/nomad nomad

# fnm
eval "$(fnm env --use-on-cd --shell zsh)"

# Python
# alias python=/usr/local/bin/python3
alias python=/opt/homebrew/bin/python3
alias pip=/opt/homebrew/bin/pip3

# Ruby
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
# By default, binaries installed by gem will be placed into:
#   /opt/homebrew/lib/ruby/gems/3.1.0/bin
export PATH="/opt/homebrew/lib/ruby/gems/3.1.0/bin:$PATH"
#
# You may want to add this to your PATH.
#
# ruby is keg-only, which means it was not symlinked into /opt/homebrew,
# because macOS already provides this software and installing another version in
# parallel can cause all kinds of trouble.
#
# If you need to have ruby first in your PATH, run:
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
#
# For compilers to find ruby you may need to set:
#   export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
#   export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"
#
# For pkg-config to find ruby you may need to set:
#   export PKG_CONFIG_PATH="/opt/homebrew/opt/ruby/lib/pkgconfig"


# Android
export ANDROID_SDK=/Users/kevin/Library/Android/sdk

# bun completions
[ -s "/Users/kevin/.bun/_bun" ] && source "/Users/kevin/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# For cURL w/ HTTP3 support
# https://gist.github.com/xmlking/cff9510dac9281d29390392cbbb033a8
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# https://github.com/tobi/try
eval "$(ruby ~/.local/try.rb init ~/src/tries)"

# GPG TTY setup
export GPG_TTY=$(tty)
