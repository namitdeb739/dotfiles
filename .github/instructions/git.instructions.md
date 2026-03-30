---
name: Git Conventions
description: Branch naming, conventional commits, PR structure, merge strategy
---

# Git Conventions

## Branch Naming
- Format: `type/short-description` (lowercase, hyphens)
- Types: `feat/`, `fix/`, `chore/`, `docs/`, `refactor/`, `test/`, `ci/`
- Examples: `feat/user-authentication`, `fix/login-timeout`, `chore/update-deps`
- Keep branch names under 50 characters

## Commit Messages
- Format: `type(scope): description`
- Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert
- Subject line: imperative mood, under 72 chars, no period at end
- Body: explain what and why (not how), wrap at 72 chars
- Breaking changes: add `!` after type/scope, explain in body

## Pull Requests
- Title: concise summary under 70 chars
- Body structure: Summary (bullet points), Type of Change, Test Plan
- One logical change per PR — split large changes into stacked PRs
- Link related issues/tickets in the description

## Merge Strategy
- Prefer squash merge for feature branches (clean history)
- Use merge commit for release/integration branches (preserve history)
- Rebase to update feature branches from main (avoid merge commits in feature branches)
- Delete branches after merge

## General
- Never force-push to main/master
- Never commit secrets, credentials, or large binary files
- Use .gitignore appropriate for the project language/framework
- Write meaningful commit messages — the git log is documentation
