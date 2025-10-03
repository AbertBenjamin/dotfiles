# prompt
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' formats 'on %F{red}%b%f '

precmd () { 
  [[ -n "$TMUX" ]] && tmux refresh-client -S 2>/dev/null
  vcs_info
  if git diff-index --quiet HEAD -->> /dev/null 2>&1; then
    zstyle ':vcs_info:*' formats 'on %F{red}%b%f '
  else 
    zstyle ':vcs_info:*' formats  'on %F{red}%b*%f '
  fi
}

#%n@%m
PROMPT='%F{cyan}%1~%f ${vcs_info_msg_0_}
 ➜ '

