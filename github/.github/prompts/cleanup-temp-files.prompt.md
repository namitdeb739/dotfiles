---
name: cleanup-temp-files
description: "Find and clean temporary files and directories safely with preview-first execution"
agent: "Universal Janitor"
argument-hint: "Optional scope or patterns (for example .copilot-tracking, caches, build outputs)"
---

# Cleanup Temp Files

Preferred custom agent: Universal Janitor.

Clean temporary files and directories in this workspace.

${input:scope:Optional path or pattern scope (leave blank for default workspace scan)}

Requirements:

- Start with discovery and dry-run only. Do not delete anything on first pass.
- Include likely temporary targets such as:
  - `.copilot-tracking/`
  - `__pycache__/`, `.pytest_cache/`, `.ruff_cache/`
  - `.mypy_cache/`, `.cache/`, `.tmp/`, `tmp/`, `temp/`
  - `.DS_Store`, `Thumbs.db`
  - language/build caches and temporary outputs that are safe to remove
- Exclude critical paths by default:
  - `.git/`
  - `node_modules/`
  - virtual environments (`.venv/`, `venv/`)
  - any file currently tracked by git, unless explicitly approved by the user
- After dry-run, present a concise deletion plan with size estimates and risk notes.
- Ask for explicit confirmation before actual deletion.
- Perform deletion only after confirmation, then re-check the workspace.

Output format:

1. Discovery summary
2. Proposed deletions (dry-run)
3. Safety exclusions and rationale
4. Confirmation checkpoint
5. Deletion results
6. Post-cleanup verification
