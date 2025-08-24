export ZDOTDIR=$HOME/.config/zsh

source $HOME/.config/zsh/zshrc
echo "sourcing $HOME/.config/zsh/zshrc"

source $HOME/.config/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh
source $HOME/.config/zsh/plugins/conda-zsh-completion/conda-zsh-completion.plugin.zsh
source $HOME/.config/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh
source $HOME/.config/zsh/plugins/fzf-tab/fzf-tab.zsh
source $HOME/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh

export PATH="$HOME/go/bin:$PATH"
export JAVA_HOME=$HOME/.sdkman/candidates/java/current
export MAVEN_HOME=$HOME/.sdkman/candidates/maven/current
export EDITOR="nvim"
export SUDO_EDITOR=nvim
