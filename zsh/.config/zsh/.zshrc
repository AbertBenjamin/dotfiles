source "$ZDOTDIR/functions.zsh"
# normal files to source
zsh_add_file "exports.zsh"
zsh_add_file "aliases.zsh"
zsh_add_file "prompt.zsh"
zsh_add_file "plugins.zsh"
autoload -Uz compinit && compinit

eval "$(direnv hook zsh)"

setopt autocd extendedglob nomatch menucomplete
setopt interactive_comments
stty stop undef
zle_highlight=('paste:none')

unsetopt BEEP

# completions
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)
zstyle ':completion:*' menu select


export KEYTIMEOUT=1
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'

#history
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
unsetopt share_history
setopt inc_append_history       # write to the history file incrementally
setopt hist_save_no_dups        # don't save duplicate entries to the history file

bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

autoload -Uz add-zsh-hook
function tmux_hook() {
  if [[ -z ${TMUX} ]]; then
    return
  fi
  tmux set-option -gq "@tmux_kubecontext_kubeconfig_#{pane_id}-#{session_id}-#{window_id}" "${KUBECONFIG}"
}
add-zsh-hook precmd tmux_hook

setopt prompt_subst


eval "$(zoxide init --cmd cd zsh)"


# Google Cloud SDK
if [ -f '/Users/Benjamin.Ostvang.Abert/Downloads/google-cloud-sdk/path.zsh.inc' ]; then 
    source '/Users/Benjamin.Ostvang.Abert/Downloads/google-cloud-sdk/path.zsh.inc'
fi

# Google Cloud SDK completion (prefer brew version if available, otherwise use downloaded version)
if [[ -f "$(brew --prefix 2>/dev/null)/share/google-cloud-sdk/completion.zsh.inc" ]]; then
    source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
elif [ -f '/Users/Benjamin.Ostvang.Abert/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then 
    source '/Users/Benjamin.Ostvang.Abert/Downloads/google-cloud-sdk/completion.zsh.inc'
fi
