#!/bin/sh
# Post a macOS notification attributed to the terminal app hosting this
# session, so a VS Code chat notifies as VS Code and a Ghostty chat as Ghostty.
#
# macOS attributes a notification to the bundle of the process that posts it,
# and the UserNotifications framework refuses bundle-id spoofing -- which is why
# terminal-notifier dropped -sender in 3.0. So notifications are posted from a
# per-host app bundle wrapping a copy of osascript, built lazily on first use
# under ~/.claude/notifiers/ and carrying the host terminal's icon.
#
# Deliberately no `set -Eeuo pipefail` (cf. rules/shell.md): a cosmetic notifier
# must never fail a turn, so every step here is best-effort and the script always
# exits 0. Absent an icon or a recognised host it still posts a plain banner.
#
# Usage: notify.sh <message> <subtitle>

msg=$1
subtitle=$2
[ -n "$DEBUG_NOTIFY" ] && echo "$(date) host=${__CFBundleIdentifier:-unset} term=${TERM_PROGRAM:-unset}" >> /tmp/claude-hook-check.txt

host_id=${__CFBundleIdentifier:-}
if [ -z "$host_id" ]; then
  case ${TERM_PROGRAM:-} in
    vscode) host_id=com.microsoft.VSCode ;;
    ghostty) host_id=com.mitchellh.ghostty ;;
    iTerm.app) host_id=com.googlecode.iterm2 ;;
    Apple_Terminal) host_id=com.apple.Terminal ;;
  esac
fi

slug=$(printf '%s' "${host_id:-generic}" | tr '[:upper:].' '[:lower:]-')
notifier="$HOME/.claude/notifiers/$slug.app"

if [ ! -x "$notifier/Contents/MacOS/notifier" ]; then
  host_app=""
  [ -n "$host_id" ] && host_app=$(mdfind "kMDItemCFBundleIdentifier == '$host_id'" 2>/dev/null | head -1)

  host_name="Claude Code"
  if [ -n "$host_app" ]; then
    plist="$host_app/Contents/Info.plist"
    n=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleName' "$plist" 2>/dev/null)
    [ -n "$n" ] && host_name="Claude Code ($n)"
  fi

  mkdir -p "$notifier/Contents/MacOS" "$notifier/Contents/Resources"
  cp /usr/bin/osascript "$notifier/Contents/MacOS/notifier"

  # Reuse the host app's icon so the banner looks like it came from that app.
  if [ -n "$host_app" ]; then
    icon=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIconFile' "$host_app/Contents/Info.plist" 2>/dev/null)
    case $icon in *.icns) ;; *) icon="$icon.icns" ;; esac
    [ -f "$host_app/Contents/Resources/$icon" ] &&
      cp "$host_app/Contents/Resources/$icon" "$notifier/Contents/Resources/appicon.icns"
  fi

  cat > "$notifier/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key><string>$host_name</string>
  <key>CFBundleDisplayName</key><string>$host_name</string>
  <key>CFBundleIdentifier</key><string>com.namit.claudecode.notifier.$slug</string>
  <key>CFBundleExecutable</key><string>notifier</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0</string>
  <key>CFBundleIconFile</key><string>appicon</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST

  codesign --force --sign - "$notifier" >/dev/null 2>&1
fi

"$notifier/Contents/MacOS/notifier" - "$msg" "$subtitle" <<'OSA' >/dev/null 2>&1
on run argv
  display notification (item 1 of argv) with title "Claude Code" subtitle (item 2 of argv) sound name "Ping"
end run
OSA
exit 0
