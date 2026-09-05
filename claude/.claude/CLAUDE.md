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
- `~/Developer/dotfiles/claude/.claude/settings.json` is write-protected against
  the agent. Changes there are proposed to the user, not applied directly.
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

## Compaction

When compacting, always preserve: the list of files modified so far, the current
branch, and the exact build/test commands in use.
