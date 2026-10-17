#!/usr/bin/env bash
# Kubectl context for tmux status bar. Prints nothing unless there is a real context.
# Reads current-context straight from kubeconfig, so kubectl doesn't have to be on
# the tmux server's PATH (it's often only in a project's nix devshell).

IFS=: read -ra configs <<< "${KUBECONFIG:-$HOME/.kube/config}"
for cfg in "${configs[@]}"; do
    [[ -r "$cfg" ]] || continue
    context="$(awk '/^current-context:/ { gsub(/["'\'']/, "", $2); print $2; exit }' "$cfg")"
    [[ -n "$context" ]] && break
done
[[ -n "$context" ]] || exit 0

if command -v kubectl &>/dev/null; then
    namespace="$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"
    echo "☸ ${context}:${namespace:-default} "
else
    echo "☸ ${context} "
fi
