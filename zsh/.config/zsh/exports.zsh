export EDITOR="nvim"
export GH_EDITOR="nvim"
export SUDO_EDITOR="nvim"

# Kubernetes
export KUBECONFIG="$HOME/.kube/config"

# Go build with OpenSSL dependency
if [[ -x /opt/homebrew/bin/brew ]]; then
    export CGO_CFLAGS="-I$(brew --prefix openssl)/include"
    export CGO_LDFLAGS="-L$(brew --prefix openssl)/lib"
fi

# SDKMAN - initialized first before PATH modifications
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
export JAVA_HOME=$HOME/.sdkman/candidates/java/current
export MAVEN_HOME=$HOME/.sdkman/candidates/maven/current

# PATH modifications (after SDKMAN to avoid conflicts)
# Deduplicate PATH automatically (prevents duplicates on reload)
typeset -U path

# Prepend custom paths to PATH (in reverse order since we're prepending)
path=("/Applications/IntelliJ IDEA.app/Contents/MacOS" $path)
path=("$HOME/Library/Application Support/JetBrains/Toolbox/scripts" $path)
path=("$HOME/.config/tmux/scripts" $path)
path=("$HOME/go/bin" $path)

