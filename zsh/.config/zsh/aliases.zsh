alias vi="nvim"
alias h="history -10"
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias k="kubectl"
# Claude Code tar et snapshot av shellet; hold agentens ls/cat standard
if [[ -z $CLAUDECODE ]]; then
  alias ls=eza
  alias cat=bat
fi
# alias cd="zoxide"
alias la="ls -a"
alias c="clear -x"
alias fzf="fzf --preview='cat {}'"

alias gs="git status"
alias gd="git diff"
gdt() { git difftool -d "${@:-HEAD}"; }
alias gc="git commit"
alias ga="git add"
alias pull="git pull"
alias push="git push"
alias gl="git log --oneline --graph"
alias gb="git branch"
alias g="git"
