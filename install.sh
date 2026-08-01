#!/bin/sh
# Install Gauntlet on macOS.
#
#   curl -fsSL https://raw.githubusercontent.com/rathojohn/gauntlet-releases/main/install.sh | sh
#
# Installing with curl rather than a browser is deliberate. macOS quarantine is
# applied by the downloading application, not by the system: browsers and Mail
# opt in, command line tools do not. The same file fetched by a browser is
# blocked by Gatekeeper until it is cleared by hand in System Settings, because
# these builds are ad-hoc signed rather than notarized. Fetched this way there
# is nothing to clear.
#
# Ad-hoc signing is not a security claim. It gives the bundle a stable code
# identity so a notification permission survives an update instead of being
# asked for again. It does not attest who built it. If that matters to you,
# build from source.

set -eu

REPO="rathojohn/gauntlet-releases"
APP="/Applications/Gauntlet.app"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

say() { printf '  %s\n' "$1"; }

case "$(uname -s)" in
  Darwin) ;;
  *) say "This installer is macOS only. On Windows use the .exe from the releases page."; exit 1 ;;
esac

say "Finding the latest release..."
ASSET_URL=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" \
  | grep -o '"browser_download_url": *"[^"]*\.dmg"' \
  | head -1 \
  | sed 's/.*"browser_download_url": *"//; s/"$//')

if [ -z "${ASSET_URL:-}" ]; then
  say "No .dmg found in the latest release of $REPO."
  exit 1
fi

say "Downloading $(basename "$ASSET_URL")"
curl -fsSL --progress-bar -o "$TMP/gauntlet.dmg" "$ASSET_URL"

say "Mounting..."
MOUNT=$(hdiutil attach -nobrowse -readonly "$TMP/gauntlet.dmg" | tail -1 | cut -f3-)
[ -n "$MOUNT" ] || { say "Could not mount the disk image."; exit 1; }

# Detach even if the copy fails, so a failed install does not leave a volume
# mounted and the next attempt refusing with "resource busy".
cleanup_mount() { hdiutil detach "$MOUNT" -force >/dev/null 2>&1 || true; }
trap 'cleanup_mount; rm -rf "$TMP"' EXIT

if [ -d "$APP" ]; then
  say "Replacing the existing install..."
  rm -rf "$APP"
fi

say "Installing to $APP"
cp -R "$MOUNT/Gauntlet.app" "$APP"
cleanup_mount

# Belt and braces: curl does not set this, but a re-run over a browser-placed
# copy might inherit one.
xattr -dr com.apple.quarantine "$APP" 2>/dev/null || true

say ""
say "Installed. Gauntlet needs Node 22+ and an authenticated claude or codex CLI."
say "Open it with:  open -a Gauntlet"
say ""

# Sync check: 0c02a5b
