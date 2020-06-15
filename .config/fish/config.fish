# ~/.config/fish/config.fish
starship init fish | source

# aliases
alias g='git'
alias gc='git checkout'
alias gcm='git checkout master'
alias grhh='git reset --hard HEAD'
alias gp='git pull'
alias k='kubectl'
alias emacs='emacs -nw'

# Enable AWS CLI autocompletion: github.com/aws/aws-cli/issues/1079
# https://github.com/aws/aws-cli/issues/1079#issuecomment-541997810
complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'
