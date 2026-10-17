# Minimal Darcula Theme for tmux
# Matches darculasolid.nvim colorscheme
#
# This file is sourced by tmux.conf after plugins load
# Colors: bg=#2B2B2B, fg=#A9B7C6, blue=#6897BB, orange=#CC7832, green=#6A8759, gray=#808080/#555555

# Status bar with transparent background
set-option -g status-style "fg=#A9B7C6,bg=default"

# Window status
set-option -g window-status-format " #I:#W#{?@agent, #{@agent},} "
set-option -g window-status-current-format " #I:#W#{?@agent, #{@agent},} "
set-option -g window-status-style "fg=#808080,bg=default"
set-option -g window-status-current-style "fg=#6897BB,bg=default,bold"
set-option -g window-status-separator ""

# Agent status (@agent, set by scripts/agent-status from Claude Code hooks): clear ✓ once seen
set-hook -g session-window-changed[90] 'if -F "#{==:#{@agent},✓}" "set -wu @agent"'
set-hook -g client-session-changed[90] 'if -F "#{==:#{@agent},✓}" "set -wu @agent"'

# Status bar content - docker + kubectl context + prefix indicator on left, agents (all sessions) + load + hostname on right
set-option -g status-left "#[fg=#6897BB]#(~/.config/tmux/scripts/docker-context.sh)#(~/.config/tmux/scripts/kubectl-context.sh)#[fg=#FFC66D]#{?client_prefix,⌨ ,}"
set-option -g status-right "#[fg=#FFC66D]#(~/.config/tmux/scripts/agent-summary)#[fg=#6A8759]#(cat /proc/loadavg 2>/dev/null | cut -d' ' -f1 || uptime | awk '{print $(NF-2)}' | tr -d ',') #[fg=#808080]| #[fg=#CC7832]#H "
set-option -g status-left-length 100
set-option -g status-right-length 50

# Pane borders
set-option -g pane-border-style "fg=#555555"
set-option -g pane-active-border-style "fg=#6897BB"

# Message style
set-option -g message-style "fg=#2B2B2B,bg=#6897BB"
set-option -g message-command-style "fg=#2B2B2B,bg=#CC7832"

# Mode style (copy mode, etc.)
set-option -g mode-style "fg=#2B2B2B,bg=#6897BB"
