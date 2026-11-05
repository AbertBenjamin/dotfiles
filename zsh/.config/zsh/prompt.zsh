# prompt
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' formats 'on %F{red}%b%f '

precmd () { 
  vcs_info
  if git diff-index --quiet HEAD -->> /dev/null 2>&1; then
    zstyle ':vcs_info:*' formats 'on %F{red}%b%f '
  else 
    zstyle ':vcs_info:*' formats  'on %F{red}%b*%f '
  fi
}

# show user@host only when logged in over ssh
[[ -n "$SSH_CONNECTION" ]] && prompt_host='%F{yellow}%n@%m%f '

PROMPT='${prompt_host}%F{cyan}%1~%f ${vcs_info_msg_0_}
 ➜ '

