#!/usr/bin/env bash
# macos.sh — macOS system preferences.
#
# Everything else in this repo configures tools; this configures the OS itself.
# Run by bootstrap.sh, and safe to re-run: every setting is declarative.
#
# Nothing here touches security posture (FileVault, Gatekeeper, SIP) or
# anything that needs sudo — those are deliberate manual decisions.
#
# Usage: ./macos.sh [--dry-run]

set -Eeuo pipefail

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "macos.sh: not macOS, skipping"
  exit 0
fi

# Wrap `defaults` so --dry-run prints instead of writing.
d() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "  [dry-run] defaults $*"
  else
    defaults "$@"
  fi
}

echo "--- Menu bar ---"
# SketchyBar draws its own bar at the top of the screen. Without this the
# native menu bar sits behind it and you get two stacked bars.
#
# Auto-hide rather than remove: the native bar still slides down when the
# pointer reaches the top edge, so the Apple menu and per-app menus remain
# reachable. Revert with:
#   defaults delete NSGlobalDomain _HIHideMenuBar && killall SystemUIServer
d write NSGlobalDomain _HIHideMenuBar -bool true

echo "--- Keyboard ---"
# Fast key repeat. KeyRepeat=1 is the fastest the UI exposes; 15 is ~225ms
# before repeating starts. Both matter constantly in vim-style editing.
d write NSGlobalDomain KeyRepeat -int 2
d write NSGlobalDomain InitialKeyRepeat -int 15
# Hold a key to repeat it rather than showing the accent picker — required for
# hjkl-style navigation to behave.
d write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# Full keyboard access: Tab moves between all controls, not just text fields.
d write NSGlobalDomain AppleKeyboardUIMode -int 3

echo "--- Text input ---"
# Smart quotes and dashes corrupt code and commit messages.
d write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
d write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
d write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
d write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
d write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

echo "--- Finder ---"
# Show what a developer needs to see: extensions, path bar, status bar.
d write NSGlobalDomain AppleShowAllExtensions -bool true
d write com.apple.finder ShowPathbar -bool true
d write com.apple.finder ShowStatusBar -bool true
# Keep hidden files visible; dotfiles are the whole point of this repo.
d write com.apple.finder AppleShowAllFiles -bool true
# Search the current folder by default, not the whole Mac.
d write com.apple.finder FXDefaultSearchScope -string "SCcf"
# List view everywhere.
d write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# Don't litter network shares and USB drives with .DS_Store.
d write com.apple.desktopservices DSDontWriteNetworkStores -bool true
d write com.apple.desktopservices DSDontWriteUSBStores -bool true
# No warning when changing a file extension.
d write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo "--- Dock ---"
# Autohide with no delay and a fast animation — the delay is the annoying part.
d write com.apple.dock autohide -bool true
d write com.apple.dock autohide-delay -float 0
d write com.apple.dock autohide-time-modifier -float 0.15
# Don't reorder spaces by use; stable positions make keyboard switching viable.
d write com.apple.dock mru-spaces -bool false
# No "recent applications" section.
d write com.apple.dock show-recents -bool false

echo "--- Screenshots ---"
# Keep the desktop clean; PNG without the drop shadow.
mkdir -p "$HOME/Pictures/Screenshots"
d write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
d write com.apple.screencapture type -string "png"
d write com.apple.screencapture disable-shadow -bool true

echo "--- Misc ---"
# Expanded save and print dialogs by default.
d write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
d write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
# Save to disk by default, not iCloud.
d write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
# Disable the "Are you sure you want to open this application?" dialog.
d write com.apple.LaunchServices LSQuarantine -bool false

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo
  echo "Dry run — nothing changed."
  exit 0
fi

echo "--- Restarting affected apps ---"
# Finder and Dock cache their preferences; without this the changes appear
# only after the next login.
for app in Finder Dock; do
  killall "$app" >/dev/null 2>&1 || true
done

echo
echo "Done. Some settings only apply to newly launched apps."
echo "Keyboard repeat rate needs a logout to take full effect."
