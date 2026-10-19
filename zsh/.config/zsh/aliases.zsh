vi() {
  if [[ $# -eq 1 && $1 == - && -t 0 ]]; then
    nvim -c "normal! '0"
  elif [[ $# -eq 1 && $1 != -* && ! -e $1 ]]; then
    # Not a path here: search downwards for a matching file
    local -a matches flags
    [[ $1 == */* ]] && flags=(--full-path)
    matches=(${(f)"$(fd --type f --hidden --exclude .git $flags -- "$1" 2>/dev/null)"})
    if (( ${#matches} == 1 )); then
      nvim "$matches[1]"
    elif (( ${#matches} > 1 )); then
      local file
      file=$(printf '%s\n' $matches | command fzf --query "$1" --select-1 --height 40% --reverse --preview 'bat --color=always {}') && nvim "$file"
    else
      nvim "$1"
    fi
  else
    nvim "$@"
  fi
}
alias h="history -10"
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias k="kubectl"
alias ls=eza
alias cat=bat
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
