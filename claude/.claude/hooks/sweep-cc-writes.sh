#!/bin/sh
# Sweep the atomic-write staging directories Claude Code leaves behind.
#
# At sandbox init the CLI creates <root>/.claude/.cc-writes (mode 0700) as
# staging space for atomic writes -- one for the session cwd, the project root,
# each additional working directory and ~/.claude -- and the recursive mkdir
# materialises the .claude/ parent along with it. In a directory that never had
# a .claude/ that strands an empty pair forever; the CLI never cleans them up.
#
# Only a fully empty pair is swept, and only with rmdir: a .cc-writes holding a
# .tmp.<pid>.<hex> file is an atomic write in flight, and a .claude/ carrying
# real content (settings, commands, hooks) is the user's. That second rule is
# also what keeps every configured root safe -- ~/.claude and every project or
# additional directory has content beside the staging dir, so their live
# staging dir is never a candidate. The residual race is a concurrent session
# whose cwd is a directory with no .claude/ of its own; it would lose its
# staging dir and log one refused atomic write before the next sandbox init
# recreates it.
#
# Deliberately no `set -eu`: a janitor must never fail a turn, so every step is
# best-effort and the script always exits 0.

root=$(jq -r '.cwd // empty' 2>/dev/null)
[ -n "$root" ] || root=${CLAUDE_PROJECT_DIR:-$PWD}

find "$root" \
  \( -name .git -o -name node_modules -o -name .venv -o -name Library \
     -o -name .Trash \) -prune -o \
  -type d -name .cc-writes -print 2>/dev/null |
while IFS= read -r staging; do
  parent=${staging%/.cc-writes}
  case $parent in */.claude) ;; *) continue ;; esac

  # Anything beside the staging dir means the .claude/ is real, and ours.
  sibling=$(find "$parent" -mindepth 1 -maxdepth 1 ! -name .cc-writes \
    -print -quit 2>/dev/null)
  [ -z "$sibling" ] || continue

  rmdir "$staging" 2>/dev/null && rmdir "$parent" 2>/dev/null
done

exit 0
