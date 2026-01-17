#!/usr/bin/env bash
# Kubectl context display for tmux status bar
# Adapted from tmux2k kubecontext.sh

# Initialize variables
KUBECTL_BIN="kubectl"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    exit 0
fi

# Get KUBECONFIG or use default
KUBECONFIG_PATH="${KUBECONFIG:-${HOME}/.kube/config}"

# Check if kubeconfig exists
if [[ ! -e "${KUBECONFIG_PATH}" ]]; then
    exit 0
fi

# Get current context
context="$(${KUBECTL_BIN} config current-context 2>/dev/null)"
exitcode=$?
if [[ -z "${context}" ]] || [[ $exitcode != 0 ]]; then
    exit 0
fi

# Get namespace
namespace="$(${KUBECTL_BIN} config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)"
exitcode=$?
if [[ $exitcode != 0 ]]; then
    exit 0
fi
namespace="${namespace:-default}"

# Output with kubernetes symbol
echo "☸ ${context}:${namespace}"
