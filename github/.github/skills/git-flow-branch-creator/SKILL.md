---
name: git-flow-branch-creator
description: 'Analyze current changes and create semantic branches using git-flow style classification with repository-specific main-based mapping.'
---

# Branch Creator

Use this skill when the user asks to create a branch for a change.

## Analysis Framework

Classify change intent using git-flow-style categories:

- `feature`: new functionality, enhancements, non-critical improvements.
- `release`: release prep, versioning, final documentation updates.
- `hotfix`: urgent production/security fixes.

## Repository Mapping

This repository operates on a main-based flow, so category mapping is:

- Branch source defaults to `main`.
- Pull requests target `main`.
- Naming still reflects category semantics.

## Workflow

1. Inspect repository state (`git status`, `git diff` or `git diff --cached`).
2. Analyze change scope and urgency.
3. Classify into feature/release/hotfix intent.
4. Generate semantic kebab-case branch name.
5. Refresh local `main` and create the branch.

## Naming Convention

```text
feature/<short-description>
release-<x.y.z>
hotfix/<short-description>
<type>/issue-<number>-<short-description>
```

Examples:

- `feature/pr-ops-command-surface`
- `hotfix/issue-421-branch-delete-guard`
- `release-1.3.0`

## Commands

```bash
git fetch origin
git switch main
git pull --ff-only origin main
git switch -c <semantic-branch-name>
```

## Safety Checks

- If uncommitted changes are unrelated to requested work, ask before branching.
- If branch already exists, suggest an incremented or issue-linked variant.
- Never create a branch named `main` or the detected default branch.

## Validation Checklist

- Branch type classification has clear rationale.
- Generated name is lowercase kebab-case and descriptive.
- Target source branch is current `main` and up to date.
- Branch creation command completes successfully.

## Output

- Selected branch type and rationale.
- Final branch name.
- Confirmation of checkout state.
