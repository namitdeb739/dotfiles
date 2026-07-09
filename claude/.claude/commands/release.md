---
allowed-tools: Bash(git status:*), Bash(git branch:*), Bash(git log:*), Bash(git tag:*), Bash(git push:*), Bash(gh release create:*), Bash(gh release view:*)
description: Cut a release: version bump, changelog, tag, and GitHub release
---

# Cut a Release

Release the current state: `$ARGUMENTS` may specify the bump (`patch`/`minor`/`major`)
or an explicit version; otherwise infer from the Conventional Commits since the
last tag.

1. **Use the project's own tooling if it exists** — check for `just release`,
   commitizen (`cz bump`), `bump-my-version`, `release-please`, `changesets`,
   `semantic-release`, etc., and prefer that over doing it by hand.
2. Preconditions: on the default branch, clean tree, up to date with origin, and
   CI green on the latest commit. Stop if any fails.
3. Determine the next version from the last tag + the commit history (breaking →
   major, `feat` → minor, else patch), or use the argument. Respect `0.x` rules.
4. Update the changelog from the commits since the last tag (grouped by type).
5. Bump the version in the project's version files, commit, and tag `vX.Y.Z`.
6. Push the commit and tag: `git push --follow-tags`.
7. Create the GitHub release: `gh release create vX.Y.Z --notes-file <changelog-section>`
   (or let the CI publish workflow do it, if one triggers on the tag). Output the
   release URL.
