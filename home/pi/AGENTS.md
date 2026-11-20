<!-- This file is managed by nix -->

# Git worktrees

Never work directly on the main branch or in the main checkout. For any task that changes files in a git repo, work in a dedicated git worktree.

- Create worktrees inside the repo at `.claude/worktrees/<name>`, on a new local branch named `worktree-<name>`:
  `git worktree add .claude/worktrees/<name> -b worktree-<name>`
- Pick a short, kebab-case `<name>` describing the task.
- Branch from the up-to-date default branch (main). If you are already in a worktree under `.claude/worktrees/`, keep working there.
- Make all edits, and run all commands, from inside the worktree.
- If `.claude/` is not git-ignored in the repo, tell me instead of committing it.
