#!/usr/bin/env bash
# Kubectl context display for tmux status bar
# Based on tmux2k kubecontext.sh but simplified

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    exit 0
fi

# Get kubectl binary path (use default if not set)
KUBECTL_BIN="kubectl"

# Get current context
CONTEXT=$(${KUBECTL_BIN} config current-context 2>/dev/null || echo "")

if [ -z "$CONTEXT" ] || [ "$CONTEXT" = "N/A" ]; then
    exit 0
fi

# Get namespace
NAMESPACE=$(${KUBECTL_BIN} config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo "")
NAMESPACE="${NAMESPACE:-default}"

# Output with kubernetes symbol
echo "☸ ${CONTEXT}:${NAMESPACE}"
