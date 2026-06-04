# wt

A wrapper around `git worktree`. Make a worktree, jump into a shell in it, and
get your untracked `.env` files copied over from the main checkout.

Worktrees go under `<repo>/.worktrees/<name>`. The listing also shows
worktrees created by Claude (`<repo>/.claude/worktrees`) and Codex
(`~/.codex/worktrees`), tagged so you can tell which is which.

## install

```sh
just link
```

Symlinks `./wt` into `~/bin` or `/usr/local/bin`. Needs `bash` and `git`.
`fzf` is optional and enables the picker.

## usage

```sh
wt feature-x          # create branch feature-x + its worktree, cd in
wt some-branch        # branch already exists? cd into its worktree
wt                    # pick an existing worktree with fzf
wt rename feature-y   # rename current worktree's branch and dir
wt remove             # remove current worktree (alias: wt end)
wt exit               # leave the worktree shell
```

`wt <name>` makes a new branch+worktree, or jumps into the existing one if the
branch is already checked out somewhere. That includes worktrees in
`.claude/` or `~/.codex/` locations. You land in a subshell with a `[wt]`
prompt. `exit` gets you back.

## copying untracked files

A fresh worktree has none of your untracked files. `setup` clones them from
the main worktree. It runs automatically when you create a worktree, or by
hand:

```sh
wt setup
```

By default it copies `.env*`. Extend that list per-repo with a space-separated
`copy` entry:

```sh
wt set copy ".venv vendor .direnv"
```

Copies are copy-on-write (`cp -c`), so cloning big dirs is cheap. To bring
`node_modules` along instead of reinstalling it:

```sh
wt set copy "node_modules"
```

Patterns are globs matched against the path or its basename. Existing files in
the worktree are never overwritten.

## prepare hook

Run a command once after a new worktree is created:

```sh
wt set prepare "pnpm install"
```

Config is per-repo at `~/.config/wt/<repo-slug>/wt.toml`.

## listing

```
[claude]   chore/tsc-fixes-2026-05-07 elastic-payne-b039fe
           main
[codex]    codex/eng-5202-deepgram-multilingual 5aee
           ricardo/observability
```

Worktrees are classified by their location on disk, not by branch name. A
codex worktree on a `ricardo/*` branch still shows as `[codex]`. Anything in
an unknown location is listed without a tag and stays selectable.

## tests

```sh
just test
```

Plain bash, no bats or shellcheck. Covers classification, listing, branch
resolution, and config.
