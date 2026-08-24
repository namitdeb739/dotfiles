---
paths:
  - "**/*.sh"
  - "**/*.bash"
  - "**/*.zsh"
  - "**/.zsh*"
  - "**/bin/*"
  - "**/bootstrap.sh"
---

# Shell

- Open with `set -Eeuo pipefail`. The `-E` is load-bearing: without errtrace an
  `ERR` trap does not fire inside functions, so a failure in a helper passes
  silently. This exact omission hid a broken step in `bin/dotfiles-update`.
- Double-quote every expansion: `"$var"`, `"${arr[@]}"`.
- `jq` and `yq` for JSON and YAML. Never `awk`/`sed` on structured data.
- `command -v`, not `which`.
- Beware zsh: unquoted parameter expansion does **not** word-split the way bash
  does. `for x in $list` iterates once over the whole string. Use `${=list}`,
  or write the loop in bash.
