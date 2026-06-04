# wt demo. render with:  vhs demo.tape
# runs in a throwaway repo + temp HOME, so nothing real is touched.
Output demo.gif

Require git
Require zsh
Require fzf

Set Shell bash
Set FontSize 20
Set Width 1100
Set Height 720
Set Padding 24
Set Theme "Dracula"
Set WindowBar Colorful
Set TypingSpeed 55ms

# --- setup (hidden) ---
Hide
Type "export WT_REPO=$PWD PATH=$PWD:$PATH" Enter
Type "export HOME=/private/tmp/wt-demo-home SHELL=$(command -v zsh)" Enter
Type "rm -rf $HOME && mkdir -p $HOME" Enter
Type `echo 'PROMPT="%F{81}%1~%f %F{205}❯%f "' > $HOME/.zshrc` Enter
Type "git config --global user.email d@d; git config --global user.name d; git config --global init.defaultBranch main" Enter
Type "rm -rf /private/tmp/myapp && mkdir /private/tmp/myapp && cd /private/tmp/myapp" Enter
Type "git init -q && git commit -qm init --allow-empty" Enter
Type "echo API_KEY=sk-demo-123 > .env" Enter
Type "git worktree add -q .claude/worktrees/eloquent-galileo -b claude/fix-auth-redirect" Enter
Type "git worktree add -q .claude/worktrees/happy-feynman -b claude/refactor-api-client" Enter
Type "mkdir -p $HOME/.codex/worktrees/7f3a" Enter
Type "git worktree add -q $HOME/.codex/worktrees/7f3a/myapp -b codex/add-rate-limiting" Enter
Type "exec zsh" Enter
Sleep 600ms
Type "clear" Enter
Show

# --- create a worktree; the untracked .env comes along ---
Sleep 800ms
Type "wt feature-login" Sleep 700ms Enter
Sleep 2.2s
Type "cat .env" Sleep 300ms Enter
Sleep 1.8s
Type "exit" Sleep 300ms Enter
Sleep 1.2s

# --- jump between worktrees with the fzf picker ---
Type "wt" Sleep 500ms Enter
Sleep 1.8s
Type "auth" Sleep 1.3s
Enter
Sleep 1.8s
Type "git branch --show-current" Sleep 300ms Enter
Sleep 2s
Type "exit" Sleep 300ms Enter
Sleep 1.2s
