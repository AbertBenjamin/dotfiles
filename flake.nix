{
  description = "Post-install package set for AbertBenjamin/dotfiles (packages only — dotfiles themselves stay stow-managed)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }:
    let
      mkHome = system: hostModule:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs { inherit system; };
          modules = [ ./home.nix hostModule ];
        };
    in
    {
      # Usage (after installing Nix, see readme.md):
      #   home-manager switch --flake ~/dotfiles#benjamin@arch
      #   home-manager switch --flake ~/dotfiles#benjamin@macbook
      homeConfigurations."benjamin@arch" = mkHome "x86_64-linux" ./host-arch.nix;
      homeConfigurations."benjamin@macbook" = mkHome "aarch64-darwin" ./host-macbook.nix;
    };
}
