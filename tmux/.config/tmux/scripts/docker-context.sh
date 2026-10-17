#!/usr/bin/env bash
# Docker context for tmux status bar. Prints nothing for the default context.

command -v docker &>/dev/null || exit 0

context="$(docker context show 2>/dev/null)" || exit 0
[[ -n "$context" && "$context" != default ]] || exit 0

echo "🐳 ${context} "
