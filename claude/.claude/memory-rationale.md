# Why `CLAUDE.md` is short

Not loaded by Claude Code — only `CLAUDE.md` in this directory is. This file exists
so the reasoning survives without costing tokens in every session of every project.

Anthropic's guidance is that files over ~200 lines reduce adherence, and in July 2026
they deleted >80% of Claude Code's own system prompt with no measurable eval loss.
Every line in `CLAUDE.md` has to earn its place by describing something the model would
NOT do by default.

## Removed, and why

- **"Tool Preferences" table** (fd/rg/bat/eza over find/grep/cat/ls). It read as "prefer
  shell for file inspection" and drove 70% of all tool calls to Bash against 222 Reads.
  Read output is line-numbered and prompt-cached, and path-scoped rules and nested
  CLAUDE.md files only load when Claude uses Read — `cat` bypassed all of that silently.
  Those CLIs are for humans.
- **"Read files before editing"** — the Edit tool enforces it and errors if not.
- **"No hardcoded secrets"** — now `permissions.deny` in `settings.json`, which is
  enforced rather than requested.
- **`eval()`/`pickle`/`shell=True` flagging** — `hooks/security-guidance.py` already does
  this deterministically. Saying it twice is the contradictory-instruction pattern
  Anthropic removed.
- **OWASP Top 10 awareness, parameterised queries, SSRF validation** — default behaviour,
  not steering.
- **The installed-tools list** (`rg fd bat eza just uv gh jq yq tectonic difft latexdiff
  typos`). Naming them invited their use over the file tools, undoing the first bullet.
  Only the `ast-grep` preference survives, because structural search is a genuine
  capability choice rather than a spelling of `grep`.
- **"MSP430/TI device docs → `earth-computers/docs/`"** — specific to one project but
  loaded in all of them. That repo's own `CLAUDE.md` routes to `docs/bench.md`, which
  says not to re-fetch the datasheets.

## Structure

The Python and Shell sections moved to `~/.claude/rules/` with `paths:` frontmatter, so
they load only when a matching file is read rather than in every session — including the
embedded C and Astro work, where they were pure noise. **This only works because file
reads go through Read**; path-scoped rules never trigger on `cat`.

Only skills and path-scoped `rules/` files defer their loading. `@`-imports are expanded
at launch and save nothing. Subdirectory `CLAUDE.md` files are documented as lazy but are
widely reported not to load at all (claude-code #24987, closed as not planned; #2571,
#18098, #3529) — prefer `rules/` with a `paths:` glob.
