# Global Claude Instructions

<!-- Short on purpose. Path-specific guidance belongs in rules/, procedural
     workflows belong in skills/. This file is only for what applies
     everywhere and is not already harness behaviour. -->

## Communication

- No trailing summaries. The diff speaks for itself.
- Ask before assuming on ambiguous requirements. One focused question beats a
  wrong implementation.
- Lead with the answer. Evidence after, not before.

## Code

- Minimal diffs. Change only what the task requires; no opportunistic cleanup.
- No speculative abstractions. Three similar lines beat a premature helper.
- No error handling for impossible states. Trust framework guarantees.
- No feature flags or compatibility shims when you can just change the code.
- Match the surrounding code's naming, comment density, and idiom.

## Verification

Formatting is applied automatically by `format-on-edit.py`, and lint diagnostics
for the edited file come back from `lint-on-edit.py`. Do not run `ruff format` by
hand after an edit.

## Shell

- Absolute paths, not `cd`: `just -f /abs/path/justfile <recipe>`, `git -C <dir>`.
- `git commit` runs inside the sandbox, pre-commit hooks included. Repos outside
  the cwd need `permissions.additionalDirectories`; dotfiles is listed there.
- `~/Developer/dotfiles/claude/.claude/` is closed to *Bash* writes — both the
  sandbox and the auto mode classifier block them, so `dangerouslyDisableSandbox`
  alone does not help, and `git rm` and `stow --restow` fail there too. The
  Edit/Write tools work fine. Use those; don't stage a script.
- Slash commands run against the session cwd, not the Bash tool's. `cd` in Bash
  cannot fix a command that needs a different repo — relaunch Claude there.
- Reach for `ast-grep` over `rg` for structural code search or rewrites.

## Looking things up

- Claude Code / Anthropic API questions → the `claude-code-guide` agent, not
  WebSearch.
- Ghostty config → `ghostty +show-config --default --docs`, `+list-actions`,
  `+list-keybinds`, `+validate-config`. Authoritative and offline.

## Git

- Conventional Commits: `type(scope): description`, subject ≤ 72 chars,
  imperative mood. Body for anything non-trivial (what + why).
- Branch from `main`, PR to `main`, squash merge, delete the branch — unless the
  repo's own `CLAUDE.md` says otherwise.
- `github.com` is on the sandbox network allowlist, so `git fetch`/`pull`/`push`
  work sandboxed. Fetching still prints `fatal: failed to store: 100001` — the
  keychain credential helper is blocked; the transfer itself succeeded.
- Fetch before checking out a branch that may be behind its remote.
- `gh pr merge --delete-branch` fails its local sync in dotfiles (it rewrites the
  write-protected config files). The merge itself lands. Clean up with `git fetch`
  then `git reset --mixed origin/main` — `--hard` tries to unlink those files and
  fails, while `--mixed` moves HEAD and the index and leaves the tree alone, which
  is all that is needed since the tree already matches. Squash merges also need
  `git branch -D` for the local branch.

## Compaction

When compacting, always preserve: the list of files modified so far, the current
branch, and the exact build/test commands in use.
