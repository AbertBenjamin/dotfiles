#!/usr/bin/env bash
# Varsler når Claude er ferdig (Stop) eller venter på input (Notification).
# Ringer terminalklokka i agentens tmux-pane så vinduet flagges (monitor-bell),
# og sender skrivebordsvarsel der det finnes.
title=${1:-Claude}
dir=$(basename "$PWD")

if [[ -n $TMUX_PANE ]]; then
  tty=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null)
  [[ -w $tty ]] && printf '\a' > "$tty"
fi

if command -v notify-send >/dev/null; then
  notify-send "$title" "$dir"
elif command -v osascript >/dev/null; then
  osascript -e "display notification \"$dir\" with title \"$title\""
fi
exit 0
