```bash
git clone https://github.com/AbertBenjamin/dotfiles ~/dotfiles
```

```bash
# ~/.claude må finnes før stow, ellers symlinkes hele mappa
# (med credentials og historikk) inn i repoet
mkdir -p ~/.claude
stow */
```

## Agentisk workflow

- `wt <branch>` — ny git worktree i `<repo>.wt/<branch>` + tmux-session med `claude` og `nvim`
- `wtrm <branch>` — fjern worktree og session
- `prefix a` — åpne `claude` i en split i samme mappe
- Vinduer der en agent er ferdig eller venter flagges i tmux-statuslinjen (bell)
- nvim laster filer på nytt når agenten endrer dem (`checktime`)
- Review i nvim: `<leader>hs` godkjenn (stage) hunk, `<leader>hr` avvis (reset),
  `<leader>hq` alle hunks i quickfix. Staged = gjennomgått, unstaged = nytt fra agenten.
