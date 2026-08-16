export ZDOTDIR=$HOME/.config/zsh

# Sourced by every zsh invocation (interactive or not, login or not) — unlike
# .zshrc, this also runs for `ssh host command` and similar non-interactive
# sessions, so tools installed here (e.g. claude) resolve over plain SSH.
export PATH="$HOME/.local/bin:$PATH"
