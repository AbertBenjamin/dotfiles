# Homebrew environment setup (needs to be early for brew-installed tools)

if [[ "$OSTYPE" == darwin* ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

