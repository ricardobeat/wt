# wt

Git worktree manager.

## Commands

| Command | Description |
|---------|-------------|
| `wt` | Interactive worktree picker (requires fzf) |
| `wt <branch>` | Switch to or create a worktree for `<branch>` |
| `wt remove` / `wt end` | Remove the current worktree |
| `wt rename <name>` | Rename the current branch and worktree directory |
| `wt setup` | Copy tracked files and run prepare command |
| `wt settings` | Open per-repo config in `$EDITOR` |
| `wt set <key> <value>` | Set config: `prepare`, `copy`, or `worktrees_dir` |
| `wt --help` / `wt help` | Show help |
