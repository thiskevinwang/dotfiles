# Ensure brew can be found
# Issue seen on m1 max mbp
[[ -f /opt/homebrew/bin/brew ]] && eval $(/opt/homebrew/bin/brew shellenv)

# Setup TTY for GPG
export GPG_TTY=$(tty)

#FIG ENV VARIABLES ####
# Please make sure this block is at the start of this file.
[ -s ~/.fig/shell/pre.sh ] && source ~/.fig/shell/pre.sh
#### END FIG ENV VARIABLES ####
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

#### FIG ENV VARIABLES ####
# Please make sure this block is at the end of this file.
[ -s ~/.fig/fig.sh ] && source ~/.fig/fig.sh
#### END FIG ENV VARIABLES ####


