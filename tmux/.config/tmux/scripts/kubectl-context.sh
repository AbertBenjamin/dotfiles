#!/usr/bin/env bash
set -euo pipefail

# Simple kubectl context display for tmux status bar

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    exit 0
fi

# Get current context with timeout to prevent hanging
if ! context=$(timeout 1 kubectl config current-context 2>/dev/null); then
    exit 0
fi

if [ -z "$context" ]; then
    exit 0
fi

# Get namespace with timeout
namespace=$(timeout 1 kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || echo "")
namespace="${namespace:-default}"

# Display with kubernetes icon and colors matching darcula theme
echo "☸ ${context}:${namespace}"
