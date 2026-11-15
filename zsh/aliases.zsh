# Shared aliases. Sourced from .zshrc, but plain enough to source from any
# POSIX-ish shell too (bash, sh) if you ever need it outside zsh.

alias ls='eza'
alias ll='eza -l --git'
alias la='eza -la --git'
alias lt='eza --tree --level=2'

alias grep='rg'

alias path='echo $PATH | tr : "\n"'

alias gs="git status"
alias gl1="git log --oneline"

alias de="docker exec"
alias dl="docker logs"
alias dps="docker ps"
