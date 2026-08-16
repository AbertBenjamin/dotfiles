{ pkgs, ... }:

{
  # This is the "post-install script", not a dotfiles manager.
  # It only declares `home.packages` — no `home.file` / `xdg.configFile` here.
  # Actual configs are still symlinked in by `stow */` as before; this file's
  # only job is to make sure the tools those configs expect are installed,
  # with pinned versions via flake.lock.
  #
  # Cross-platform packages only. Linux- or macOS-only tools live in
  # hosts/arch.nix / hosts/macbook.nix instead — see flake.nix.

  # Bump only deliberately - see home-manager release notes before changing.
  home.stateVersion = "25.05";

  # Lets `home-manager` itself be invoked without going through the flake each time.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # terminal / multiplexer / editor
    tmux
    neovim
    alacritty
    ghostty

    # shell tooling referenced from zsh/.config/zsh/{aliases,functions}.zsh
    fzf
    bat
    eza
    zoxide
    fd
    direnv

    # git.config uses delta as pager (git/.config/git/config)
    delta

    # secrets workflow (.sops.yaml / secrets.yaml)
    sops
    age

    # misc CLI
    yazi
    kubectl
    stow
  ];

  # Deliberately NOT managed here, kept on the system package manager instead:
  #  - zsh          -> must be a valid login shell listed in /etc/shells
  #  - docker       -> needs the system daemon/service, not just a client binary
}
