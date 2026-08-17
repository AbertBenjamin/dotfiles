export EDITOR="nvim"
export GH_EDITOR="nvim"
export SUDO_EDITOR="nvim"

# Kubernetes
export KUBECONFIG="$HOME/.kube/config"

# Go build with OpenSSL dependency
if [[ -d /opt/homebrew/opt/openssl ]]; then
    export CGO_CFLAGS="-I/opt/homebrew/opt/openssl/include"
    export CGO_LDFLAGS="-L/opt/homebrew/opt/openssl/lib"
fi

# SDKMAN - initialized first before PATH modifications
export SDKMAN_DIR="$HOME/.sdkman"
# Deduplicate PATH automatically (prevents duplicates on reload)
typeset -U path
# sdkman-init.sh koster ~90 ms, men bidrar bare med disse PATH-oppføringene
# ved oppstart. Last hele skriptet først når `sdk` faktisk brukes.
path=($SDKMAN_DIR/candidates/*/current/bin(N) $path)
sdk() {
  unfunction sdk
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
  sdk "$@"
}
export JAVA_HOME=$HOME/.sdkman/candidates/java/current
export MAVEN_HOME=$HOME/.sdkman/candidates/maven/current

# PATH modifications (after SDKMAN to avoid conflicts)

# Prepend custom paths to PATH (in reverse order since we're prepending)
path=("/Applications/IntelliJ IDEA.app/Contents/MacOS" $path)
path=("$HOME/Library/Application Support/JetBrains/Toolbox/scripts" $path)
path=("$HOME/.config/tmux/scripts" $path)
path=("$HOME/go/bin" $path)

