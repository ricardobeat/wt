# wt

A wrapper around `git worktree`. Make a worktree, jump into a shell in it, and
get your untracked `.env` files copied over from the main checkout.

Automatically picks up existing **Claude** and **Codex** worktrees, so you can jump
in and pick up the work at any time.

![wt demo](https://vhs.charm.sh/vhs-4kC49ltnujtlwmgwJoOpP3.gif)

## install

```sh
brew install just fzf
git clone https://github.com/ricardobeat/wt
cd wt && just link
```

## usage

```sh
wt feature-x          # create branch feature-x + its worktree, cd in
wt some-branch        # branch already exists? cd into its worktree
wt                    # pick an existing worktree with fzf
wt settings           # edit this repo's config in $EDITOR
wt rename feature-y   # rename current worktree's branch and dir
wt remove             # remove current worktree (alias: wt end)
wt exit               # leave the worktree shell
```

`wt <name>` makes a new branch+worktree, or jumps into the existing one if the
branch is already checked out somewhere. That includes worktrees in
`.claude/` or `~/.codex/` locations. You land in a subshell with a `[wt]`
prompt. `exit` gets you back.

## copying untracked files

When a new worktree is created with `wt [name]`, untracked files can be copied
from the main worktree. Re-run at any time with `wt setup`.

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

## worktree location

By default worktrees go in `<repo>/.worktrees/<name>`. To use a different
location — for example a shared folder in your home directory:

```sh
wt set worktrees_dir "~/worktrees/myrepo"
```

The branch name is always appended. Tilde (`~`) is expanded to `$HOME`.

## prepare hook

Run a command after a new worktree is created (and again on `wt setup`):

```sh
wt set prepare "pnpm install"
```

Config is per-repo at `$XDG_CONFIG_HOME/wt/<repo-slug>/wt.toml` (defaults to
`~/.config`).

## copy-on-write

Files use CoW when available - so you can copy your entire `node_modules` for example,
without using extra disk space.

I still recommend using [pnpm](https://pnpm.io) (which uses symlinks) as it's a cleaner
and even faster setup.

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
