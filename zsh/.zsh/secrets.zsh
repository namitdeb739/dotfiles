# Load secrets from the macOS login Keychain.
#
# Secrets are stored as generic-password items (service "dotfiles:<NAME>") by
# `secret set`, so they are encrypted at rest and backed up by iCloud Keychain
# sync — unlike the plaintext ~/.secrets file this replaces.
#
# Manage with: secret set|get|list|rm|import
#
# Costs ~30ms at shell startup. A plaintext ~/.secrets is still sourced by
# .zshrc afterwards if present, so a machine that has not been migrated yet
# keeps working.

if [[ "$OSTYPE" == darwin* ]] && (( $+commands[secret] )); then
  # `secret export` emits shell-quoted `export NAME=value` lines.
  eval "$(secret export 2>/dev/null)"
fi
