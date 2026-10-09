# Function to source files if they exist
function zsh_add_file() {
  [ -f "$ZDOTDIR/$1" ] && source "$ZDOTDIR/$1"
}

function zsh_add_plugin() {
  PLUGIN_NAME=$(echo $1 | cut -d "/" -f 2)
  if [ -d "$ZDOTDIR/plugins/$PLUGIN_NAME" ]; then 
    # For plugins
    zsh_add_file "plugins/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh" || \
      zsh_add_file "plugins/$PLUGIN_NAME/$PLUGIN_NAME.zsh"
  else
    git clone "https://github.com/$1.git" "$ZDOTDIR/plugins/$PLUGIN_NAME"
  fi
}

function zsh_add_completion() {
  PLUGIN_NAME=$(echo $1 | cut -d "/" -f 2)
  if [ -d "$ZDOTDIR/plugins/$PLUGIN_NAME" ]; then 
    # For completions
    completion_file_path=$(ls $ZDOTDIR/plugins/$PLUGIN_NAME/_*)
    fpath+="$(dirname "${completion_file_path}")"
    zsh_add_file "plugins/$PLUGIN_NAME/$PLUGIN_NAME.plugin.zsh"
  else
    git clone "https://github.com/$1.git" "$ZDOTDIR/plugins/$PLUGIN_NAME"
    fpath+=$(ls $ZDOTDIR/plugins/$PLUGIN_NAME/_*)
    rm $ZDOTDIR/.zccompdump
  fi
}

nf() {
  local file
  file=$(fzf --preview='bat {}') && [ -n "$file" ] && nvim "$file"
}

_vs_files() {
  { git diff --name-only --relative --diff-filter=d HEAD; git ls-files --others --exclude-standard; } 2>/dev/null | sort -u
}

vs() {
  if (( $# )); then
    nvim "$@"
    return
  fi
  local files
  files=$(_vs_files | command fzf --multi --height 40% --min-height 20+ --reverse) || return
  nvim ${(f)files}
}

_vs() {
  local -a files
  files=(${(f)"$(_vs_files)"})
  compadd -f -a files
}

cdd() {
  local dir
  dir=$(fd -t d | fzf --prompt="Directory: " --height=50% --border)
  [[ -n $dir ]] && cd "$dir"
}

# Én worktree + tmux-session per agent: wt <branch>
# Lager <repo>.wt/<branch> ved siden av repoet, starter claude og nvim der
wt() {
  local branch=$1 root dir name
  [[ -n $branch ]] || { echo "bruk: wt <branch>"; return 1; }
  # hovedrepoet, også når man står i en worktree
  root=$(git rev-parse --path-format=absolute --git-common-dir) || return
  root=${root%/.git}
  dir="${root}.wt/${branch//\//_}"
  if [[ ! -d $dir ]]; then
    if git -C "$root" show-ref --verify --quiet "refs/heads/$branch"; then
      git -C "$root" worktree add "$dir" "$branch" || return
    else
      git -C "$root" worktree add -b "$branch" "$dir" || return
    fi
  fi
  name="$(basename $root)_${branch//[.\/]/_}"
  if ! tmux has-session -t "=$name" 2>/dev/null; then
    tmux new-session -ds "$name" -c "$dir" -n agent
    tmux send-keys -t "${name}:agent" "claude" C-m
    tmux new-window -t "$name" -n nvim -c "$dir" nvim
    tmux select-window -t "${name}:agent"
  fi
  if [[ -n $TMUX ]]; then
    tmux switch-client -t "$name"
  else
    tmux attach-session -t "$name"
  fi
}

# Fjern worktree og tilhørende tmux-session: wtrm <branch>
wtrm() {
  local branch=$1 root dir name
  [[ -n $branch ]] || { echo "bruk: wtrm <branch>"; return 1; }
  root=$(git rev-parse --path-format=absolute --git-common-dir) || return
  root=${root%/.git}
  dir="${root}.wt/${branch//\//_}"
  name="$(basename $root)_${branch//[.\/]/_}"
  git -C "$root" worktree remove "$dir" || return
  tmux kill-session -t "=$name" 2>/dev/null
  return 0
}
