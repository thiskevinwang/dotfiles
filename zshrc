# Fig pre block. Keep at the top of this file.
export PATH="${PATH}:${HOME}/.local/bin"
eval "$(fig init zsh pre)"

# Ensure brew can be found
# Issue seen on m1 max mbp
[[ -f /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)

# Setup TTY for GPG
export GPG_TTY=$(tty)

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/kevin/.oh-my-zsh"

# Add wisely, as too many plugins slow down shell startup.
plugins=(
    aws
    fzf
    git
    zsh-completions
    docker
    docker-compose
    zsh-autosuggestions
)

# node repl
alias repl="NODE_PATH=$(npm root -g) node"

# go-bindata
export PATH=$PATH:$(go env GOPATH)/bin
# GOPATH
export GOPATH=$(go env GOPATH)

export AWS_PAGER=""

autoload -U compinit && compinit

# Note this needs to come after plugins=(...)
# in order for plugins to load.
source $ZSH/oh-my-zsh.sh

# Kubectl
# https://kubernetes.io/docs/tasks/tools/install-kubectl/#optional-kubectl-configurations
source <(kubectl completion zsh)
alias k=kubectl
complete -F __start_kubectl k

source <(minikube completion zsh)

# 1password cli (op)
# https://developer.1password.com/docs/cli/reference/commands/completion/
eval "$(op completion zsh)"; compdef _op op

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

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

# fnm
eval "$(fnm env --use-on-cd)"

# Python
alias python=/usr/local/bin/python3

# Android
export ANDROID_SDK=/Users/kevin/Library/Android/sdk



# function
function aws_config() {
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

# Fig post block. Keep at the bottom of this file.
eval "$(fig init zsh post)"
