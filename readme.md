```bash
git clone https://github.com/AbertBenjamin/dotfiles ~/dotfiles
cd ~/dotfiles
```

## 1. Installer pakkene (nix)

Krever [Nix](https://nixos.org/download) med flakes påslått.

```bash
# denne Arch-maskinen
nix run home-manager/master -- switch --flake .#benjamin@arch     # første gang
home-manager switch --flake .#benjamin@arch                       # senere

# macOS
nix run home-manager/master -- switch --flake .#benjamin@macbook  # første gang
home-manager switch --flake .#benjamin@macbook                    # senere
```

Dette installerer/pinner verktøyene configene under forventer (felles pakker i
`home.nix`, platform-spesifikke i `host-arch.nix`/`host-macbook.nix`).
`zsh` og `docker` installeres fortsatt via systemets pakkebehandler (login shell-krav /
systemtjeneste).

## 2. Symlink configene (stow)

```bash
stow */
```
