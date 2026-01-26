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

**Verify the symlinks were created:**
```bash
ls -la ~/.config/tmux/tmux.conf
ls -la ~/.config/tmux/scripts/kubectl-context.sh
```

After running stow, reload tmux:
```bash
# Inside tmux, press: prefix + r
# Or restart tmux
tmux kill-server && tmux
```

## Kubectl Context Display

If you have kubectl configured, the status bar will show your current context and namespace:
```
☸ docker-desktop:default
```

If kubectl is not installed or no context is set, the kubectl section will be empty.

## Troubleshooting

If kubectl context is not showing:

1. **Verify stow was run correctly:**
   ```bash
   ls -la ~/.config/tmux/scripts/kubectl-context.sh
   # Should show a symlink to ~/dotfiles/tmux/.config/tmux/scripts/kubectl-context.sh
   ```

2. **Check if the script is executable:**
   ```bash
   ls -la ~/.config/tmux/scripts/kubectl-context.sh
   # Should show -rwxr-xr-x permissions
   ```
   If not executable:
   ```bash
   chmod +x ~/.config/tmux/scripts/kubectl-context.sh
   ```

3. **Test the script manually:**
   ```bash
   ~/.config/tmux/scripts/kubectl-context.sh
   # Should output: ☸ your-context:namespace
   ```

4. **Check that kubectl is working:**
   ```bash
   kubectl config current-context
   # Should output your context name (e.g., docker-desktop)
   ```

5. **Verify kubectl config has a current context:**
   ```bash
   kubectl config get-contexts
   # The current context should have a * in the CURRENT column
   ```

6. **Check tmux status-left setting:**
   ```bash
   tmux show-options -g status-left
   # Should show the kubectl-context.sh script path
   ```

7. **Reload tmux configuration:**
   ```bash
   # Inside tmux, press: prefix + r
   # Or restart tmux completely
   tmux kill-server && tmux
   ```

8. **Debug the script:**
   ```bash
   bash -x ~/.config/tmux/scripts/kubectl-context.sh
   # Shows detailed execution trace
   ```

## Common Issues

- **"Script not found"**: Make sure you ran `stow */` from the `~/dotfiles` directory
- **"No output from script"**: Check that you have a kubectl context set with `kubectl config current-context`
- **"Permission denied"**: Make the script executable with `chmod +x ~/.config/tmux/scripts/kubectl-context.sh`
