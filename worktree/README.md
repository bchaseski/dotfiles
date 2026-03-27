# wt — Git Worktree Helper

`wt` is a shell script for managing Git worktrees across multiple repos. It wraps `git worktree` with sensible conventions for branch naming, base-branch resolution, and VS Code integration.

## Installation

Via the main dotfiles installer:
```bash
./install.sh
```

Or standalone:
```bash
./worktree/install-wt.sh
```

Both copy `wt` to `/usr/local/bin/wt`.

## Usage

```
wt feature|feat <slug>   [--base <ref>]   # new feature worktree (branch: feat/<slug>)
wt hotfix <id>           [--base <ref>]   # new hotfix worktree (branch: hotfix/<id>)
wt track <branch>                         # check out an existing branch into a worktree
wt pr <number>                            # check out a PR by number
wt scratch <name>        [--base <ref>]   # throwaway worktree
wt list                                   # git worktree list
wt status                                 # table of all worktrees with active marker
wt remove <suffix>                        # remove a worktree by suffix
wt prune                                  # prune stale worktree refs
wt open <suffix>                          # open worktree in VS Code
wt switch <suffix>                        # print worktree path (use with cd)
wt cleanup-merged        [--base <ref>] [--dry-run]   # remove merged worktrees/branches
wt default-base                           # print resolved default base branch
wt base                                   # print base repo path
wt help                                   # show usage
```

## Worktree layout

Worktrees are created as siblings of the base repo, named `<repo>__<suffix>`:

```
~/dev/
  myrepo/          # base repo
  myrepo__feat-api-cleanup/
  myrepo__hotfix-123/
```

## Base branch resolution

`wt` resolves the default base branch in this order:

1. `.wtconfig` at repo root (`default-base = origin/stg`)
2. `origin/HEAD`
3. `origin/dev`
4. `origin/stg`
5. `origin/main`
6. `origin/master`

Override per-command with `--base <ref>`.

## Claude config

If the base repo has a `.claude/` directory, `wt` symlinks it into each new worktree so Claude Code picks up the same project config.

## Global flags

```
--repo <path>   use an explicit base repo instead of detecting from cwd
--root <path>   place worktrees under this directory instead of the parent of the base repo
```
