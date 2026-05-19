#!/usr/bin/env bash
# check-stow-integrity.sh — verifies all stow packages are correctly symlinked into $HOME

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Determine VS Code user dir (mirrors bootstrap.sh platform logic)
case "$(uname -s)" in
  Darwin) VSCODE_TARGET="$HOME/Library/Application Support/Code/User" ;;
  Linux)  VSCODE_TARGET="$HOME/.config/Code/User" ;;
  *)      VSCODE_TARGET="" ;;
esac

python3 - "$REPO_DIR" "$HOME" "${VSCODE_TARGET:-}" <<'PY'
from pathlib import Path
import sys

repo       = Path(sys.argv[1]).resolve()
home       = Path(sys.argv[2]).resolve()
vscode_raw = sys.argv[3]

# Packages that stow into $HOME
HOME_PACKAGES = ["git", "github", "zsh", "atuin", "starship", "nvim"]

# Build package → target mapping; skip vscode when its target dir is absent
packages: dict[str, Path] = {pkg: home for pkg in HOME_PACKAGES}
if vscode_raw:
    vscode_target = Path(vscode_raw)
    if vscode_target.is_dir():
        packages["vscode"] = vscode_target

errors: list[str] = []
checked = 0

for pkg_name, target_dir in packages.items():
    pkg_dir = repo / pkg_name
    if not pkg_dir.is_dir():
        errors.append(f"Package directory missing: {pkg_dir}")
        continue

    for pkg_file in sorted(pkg_dir.rglob("*")):
        if not pkg_file.is_file():
            continue

        # Where stow would place (or fold) this file
        rel           = pkg_file.relative_to(pkg_dir)
        expected_link = target_dir / rel

        checked += 1

        # Follow stow directory-folding: the file may be reachable through a
        # higher-level directory symlink, so use .resolve() on both sides.
        if not expected_link.exists():
            errors.append(f"[{pkg_name}] Missing: {expected_link}")
            continue

        resolved = expected_link.resolve()
        expected = pkg_file.resolve()
        if resolved != expected:
            errors.append(
                f"[{pkg_name}] Wrong target: {expected_link} resolves to {resolved} "
                f"(expected {expected})"
            )

if errors:
    print(f"Stow integrity check FAILED: {len(errors)} issue(s) found")
    for err in errors:
        print(f"  {err}")
    sys.exit(1)

pkg_list = ", ".join(packages)
print(f"OK: {checked} files across [{pkg_list}] all resolve into the dotfiles repo")
PY
