export ZDOTDIR=$HOME/.config/zsh

source $HOME/.config/zsh/zshrc
echo "sourcing $HOME/.config/zsh/zshrc "
source $HOME/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $HOME/.config/zsh/plugins/conda-zsh-completion/conda-zsh-completion.plugin.zsh
source $HOME/.config/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh
source $HOME/.config/zsh/plugins/fzf-tab/fzf-tab.zsh

export JAVA_HOME=$HOME/.sdkman/candidates/java/current
export MAVEN_HOME=$HOME/.sdkman/candidates/maven/current
export EDITOR="nvim"
