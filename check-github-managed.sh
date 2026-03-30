#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_GITHUB="${HOME}/.github"

if [[ ! -e "${HOME_GITHUB}" ]]; then
  echo "ERROR: ${HOME_GITHUB} does not exist"
  exit 2
fi

python3 - "${REPO_DIR}" "${HOME_GITHUB}" <<'PY'
from pathlib import Path
import subprocess
import sys

repo = Path(sys.argv[1]).resolve()
home_github = Path(sys.argv[2]).resolve()

tracked_rel = subprocess.check_output(
    ["git", "-C", str(repo), "ls-files"],
    text=True,
).splitlines()
tracked_abs = {str((repo / p).resolve()) for p in tracked_rel}

visible_files = subprocess.check_output(
    ["find", "-L", str(home_github), "-type", "f"],
    text=True,
).splitlines()

unmanaged = []
for visible in sorted(visible_files):
    real = str(Path(visible).resolve())
    if real not in tracked_abs:
        unmanaged.append((visible, real))

if unmanaged:
    print(f"Unmanaged files found: {len(unmanaged)}")
    for visible, real in unmanaged:
        print(f"- {visible} -> {real}")
    sys.exit(1)

print(f"OK: all {len(visible_files)} files under {home_github} are managed by dotfiles")
PY