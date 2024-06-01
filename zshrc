# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
# Rebind "Ctrl+f" — https://github.com/withfig/fig/issues/1583
export FIG_WORKFLOWS_KEYBIND=""

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
    zsh-completions
    zsh-autosuggestions
)

# node repl
# - this WARNS
# alias repl="NODE_PATH=$(npm root -g) node"
# - use this instead
alias repl="NODE_PATH=$(npm root --location=global) node"

alias dm="dark-mode"

# Fix this error:
# complete:13: command not found: compdef
autoload -Uz compinit
compinit

# OpenAI
. "$HOME/.openai/credentials"

# ensure brew is in path
export PATH=/opt/homebrew/bin:$PATH

# deno
export PATH="$HOME/.deno/bin:$PATH"

# go-bindata
export PATH=$PATH:$(go env GOPATH)/bin
# GOPATH
export GOPATH=$(go env GOPATH)

export AWS_PAGER=""


# Note this needs to come after plugins=(...)
# in order for plugins to load.
source $ZSH/oh-my-zsh.sh

# Starship Prompt
export STARSHIP_CONFIG="$HOME/starship.toml"
eval "$(starship init zsh)"

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Sounds...
# # Turn off all beeps
# unsetopt BEEP
# Turn off autocomplete beeps
unsetopt LIST_BEEP


# Added by Amplify CLI binary installer
export PATH="$HOME/.amplify/bin:$PATH"

# The next line updates PATH for Netlify's Git Credential Helper.
if [ -f '/Users/kevin/.netlify/helper/path.zsh.inc' ]; then source '/Users/kevin/.netlify/helper/path.zsh.inc'; fi

# Terraform
autoload -U +X bashcompinit && bashcompinit
alias tf=terraform

# TAB COMPLETIONS — Semi redundant given Fig's completion
## Terraform
complete -o nospace -C /opt/homebrew/bin/terraform terraform
## Nomad
complete -o nospace -C /opt/homebrew/bin/nomad nomad

# fnm
eval "$(fnm env --use-on-cd)"

# Python
# alias python=/usr/local/bin/python3
alias python=/opt/homebrew/bin/python3
alias pip=/opt/homebrew/bin/pip3
alias ls=/opt/homebrew/bin/exa

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


# function
function aws_config() {
		aws_config_clear

		echo "============"
    echo " AWS Config "
    echo "============"
    
    access_key_id_label="Access key ID"
    secret_access_key_label="Secret access key"

    eval $(op signin)

    AWS_ACCESS_KEY_ID=$(op item get "AWS" --fields label=$access_key_id_label)
    AWS_SECRET_ACCESS_KEY=$(op item get "AWS" --fields label=$secret_access_key_label)
    
    if [ -e ~/.aws/credentials ]; then
        rm ~/.aws/credentials
    fi


    eval $(export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID)
    eval $(export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY)

    aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
    aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY

    echo "✅"
}

function aws_config_clear() {
    echo "=================="
    echo " AWS Config Clear "
    echo "=================="
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    unset AWS_SESSION_TOKEN
    unset AWS_SESSION_EXPIRATION
}

function get_ghcr_token() {
	# check 1password signin status
	EXIT_CODE=0
	op account get > /dev/null 2>&1 || EXIT_CODE=$?
	if [ $EXIT_CODE -gt 0 ]; then
		eval $(op signin)
	fi
	echo $(op item get "github" --format=json --fields label=CR_PAT | jq -r ".value")
}

function get_gh_token() {
	# check 1password signin status
	EXIT_CODE=0
	op account get > /dev/null 2>&1 || EXIT_CODE=$?
	if [ $EXIT_CODE -gt 0 ]; then
		eval $(op signin)
	fi
	echo $(op item get "github" --format=json --fields label=PAT | jq -r ".value")
}


# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"

# bun completions
[ -s "/Users/kevin/.bun/_bun" ] && source "/Users/kevin/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
