{ pkgs, ... }:

{
  # ASSUMPTION - taken from the Google Cloud SDK path guarded in
  # zsh/.config/zsh/.zshrc ("/Users/Benjamin.Ostvang.Abert/..."). Fix this if
  # the actual macOS account name differs.
  home.username = "Benjamin.Ostvang.Abert";
  home.homeDirectory = "/Users/Benjamin.Ostvang.Abert";

  home.packages = [
    # No macOS-only additions yet. karabiner-elements and AeroSpace stay on
    # Homebrew: karabiner needs a system extension/installer nix can't
    # provide, and GUI .app bundles are generally better managed via brew
    # casks on Darwin than through nixpkgs.
  ];
}
