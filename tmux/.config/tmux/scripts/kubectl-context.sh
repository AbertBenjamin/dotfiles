#!/usr/bin/env bash
# Simple kubectl context display for tmux status bar

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    exit 0
fi

# Get current context with timeout to prevent hanging
context=$(timeout 1 kubectl config current-context 2>/dev/null)

if [ -z "$context" ] || [ $? -ne 0 ]; then
    exit 0
fi

# Get namespace with timeout
namespace=$(timeout 1 kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
namespace="${namespace:-default}"

# Display with kubernetes icon and colors matching darcula theme
echo "☸ ${context}:${namespace}"
