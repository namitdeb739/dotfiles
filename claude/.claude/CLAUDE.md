# Global Claude Instructions

<!--
  Kept deliberately short. Anthropic's guidance is that files over ~200 lines
  reduce adherence, and in July 2026 they deleted >80% of Claude Code's own
  system prompt with no measurable eval loss. Every line below has to earn its
  place by describing something the model would NOT do by default.

  Removed, and why:
  - "Tool Preferences" table (fd/rg/bat/eza over find/grep/cat/ls). It read as
    "prefer shell for file inspection" and drove 70% of all tool calls to Bash
    against 222 Reads. Read output is line-numbered and prompt-cached, and
    path-scoped rules and nested CLAUDE.md files only load when Claude uses
    Read — `cat` bypassed all of that silently. Those CLIs are for humans.
  - "Read files before editing" — the Edit tool enforces it and errors if not.
  - "No hardcoded secrets" — now permissions.deny in settings.json, which is
    enforced rather than requested.
  - eval()/pickle/shell=True flagging — hooks/security-guidance.py already does
    this deterministically. Saying it twice is the contradictory-instruction
    pattern Anthropic removed.
  - OWASP Top 10 awareness, parameterised queries, SSRF validation — default
    behaviour, not steering.

  The Python and Shell sections moved to ~/.claude/rules/ with `paths:`
  frontmatter, so they load only when a matching file is read rather than in
  every session — including the embedded C and Astro work, where they were
  pure noise. Note this only works because file reads now go through Read;
  path-scoped rules never trigger on `cat`.
-->

## Communication

- No trailing summaries. The diff speaks for itself.
- Ask before assuming on ambiguous requirements. One focused question beats a
  wrong implementation.

## Code

- Minimal diffs. Change only what the task requires; no opportunistic cleanup.
- No speculative abstractions. Three similar lines beat a premature helper.
- No error handling for impossible states. Trust framework guarantees.
- No feature flags or compatibility shims when you can just change the code.

## Shell

- Absolute paths, not `cd`. Read/Grep/Glob/Edit need no cwd; `just -f
  /abs/path/justfile <recipe>` and `git -C <dir>` cover the rest.
- **`git commit` is the exception: issue it bare and alone.** No `-C <dir>`, and
  never chained behind `git add ... &&`. Commits are SSH-signed and the sandbox
  denies `~/.ssh` and the ssh-agent socket, so signing works only via the
  `git commit *` entry in `sandbox.excludedCommands` — a prefix match with a
  trailing wildcard, which `git -C <dir> commit` and `git add x && git commit`
  both miss. They then run sandboxed and fail with `Couldn't load public key`
  then `failed to write commit object`. Stage in one call, commit in the next,
  from the repo's own cwd. To commit in a *different* repo, either add
  `git -C * commit *` to `excludedCommands` or use `dangerouslyDisableSandbox`
  for that one call.
- Use Read/Grep/Glob/Edit over `cat`/`grep`/`find`/`sed -i`. `sed -i` in
  particular skips `format-on-edit.py` and the LSP diagnostics loop.
- Installed and preferred: `rg fd bat eza just uv gh jq yq tectonic ast-grep
  difft latexdiff typos`. Reach for `ast-grep` over `rg` for structural
  code search or rewrites.

## Looking things up

- Claude Code / Anthropic API questions → the `claude-code-guide` agent, not
  WebSearch.
- Ghostty config → `ghostty +show-config --default --docs`, `+list-actions`,
  `+list-keybinds`, `+validate-config`. Authoritative and offline.
- MSP430/TI device docs → download once into `earth-computers/docs/`, then read
  locally. Don't re-fetch the same datasheet from ti.com.

## Git

- Conventional Commits: `type(scope): description`, subject ≤ 72 chars,
  imperative mood. Body for anything non-trivial (what + why).
- Branch from `main`, PR to `main`, squash merge, delete the branch.

## Compaction

When compacting, always preserve: the list of files modified so far, the
current branch, and the exact build/test commands in use.
