# Tmux Configuration

This tmux configuration uses a minimal Darcula theme matching the darculasolid.nvim colorscheme.

## Features

- Transparent status bar background
- Kubectl context display with kubernetes icon (☸)
- Darcula color palette (#6897BB blue, #CC7832 orange, #6A8759 green, #A9B7C6 foreground)
- No session name on status bar (kubectl context only)

## Setup

**Important:** You must run stow to create symlinks before using this configuration:

```bash
cd ~/dotfiles
stow */
```

This will create symlinks like:
- `~/.config/tmux/tmux.conf` → `~/dotfiles/tmux/.config/tmux/tmux.conf`
- `~/.config/tmux/scripts/kubectl-context.sh` → `~/dotfiles/tmux/.config/tmux/scripts/kubectl-context.sh`

After running stow, reload tmux:
```bash
# Inside tmux, press: prefix + r
# Or restart tmux
```

## Kubectl Context Display

If you have kubectl configured, the status bar will show your current context and namespace:
```
☸ docker-desktop:default
```

If kubectl is not installed or no context is set, the kubectl section will be empty.

## Troubleshooting

If kubectl context is not showing:

1. Make sure you've run `stow */` from the `~/dotfiles` directory
2. Verify the script is executable:
   ```bash
   ls -la ~/.config/tmux/scripts/kubectl-context.sh
   ```
3. Test the script manually:
   ```bash
   ~/.config/tmux/scripts/kubectl-context.sh
   ```
4. Check that kubectl is working:
   ```bash
   kubectl config current-context
   ```
5. Reload tmux configuration: prefix + r
