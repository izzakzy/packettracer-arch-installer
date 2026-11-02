#!/usr/bin/env bash
# Install Cisco Packet Tracer on Arch Linux using the AUR "packettracer" package.
# You must download the Cisco .deb yourself (it needs a login); this script does the rest.
set -euo pipefail

AUR_URL="https://aur.archlinux.org/packettracer.git"
WORKDIR="${XDG_CACHE_HOME:-$HOME/.cache}/packettracer-install"
APPIMAGE="/usr/lib/packettracer/packettracer.AppImage"
MIN_SIZE=$((50 * 1024 * 1024))
DEB=""

die()  { echo "error: $*" >&2; exit 1; }
info() { echo "==> $*"; }

usage() {
  cat << USAGE
Usage: ./install.sh [path/to/CiscoPacketTracer_*.deb]

If no path is given, the newest ~/Downloads/CiscoPacketTracer*.deb is used.
USAGE
}

case "${1:-}" in
  -h|--help) usage; exit 0 ;;
  -*)        usage; die "unknown option: $1" ;;
  *)         DEB="${1:-}" ;;
esac

[[ $EUID -ne 0 ]] || die "run as a normal user, not root (makepkg refuses root)"
command -v pacman >/dev/null || die "this script is for Arch Linux (pacman not found)"

# 1. Locate the Cisco installer
if [[ -z "$DEB" ]]; then
  shopt -s nullglob
  candidates=("$HOME"/Downloads/CiscoPacketTracer*.deb)
  shopt -u nullglob
  [[ ${#candidates[@]} -gt 0 ]] || die "no CiscoPacketTracer*.deb in ~/Downloads. See README step 1."
  DEB="$(ls -t "${candidates[@]}" | head -1)"
fi
[[ -f "$DEB" ]] || die "file not found: $DEB"
info "Using installer: $DEB"

# 2. Validate it (Cisco's links expire in 30s and the browser then saves an error page as .deb)
size="$(stat -c%s "$DEB")"
if (( size < MIN_SIZE )) || ! file -b "$DEB" | grep -q "Debian binary package"; then
  echo "--- file says: $(file -b "$DEB" | cut -c1-120)"
  echo "--- size: $size bytes"
  die "that is not a real Packet Tracer .deb (probably an expired-link error page). Download it again, right after clicking the link."
fi

# 3. Dependencies
info "Installing build dependencies (sudo required)"
sudo pacman -S --needed base-devel git fuse2

# 4. Fetch the AUR build recipe
mkdir -p "$WORKDIR"
cd "$WORKDIR"
if [[ -d packettracer/.git ]]; then
  info "Updating AUR recipe"
  git -C packettracer pull --ff-only
else
  info "Cloning AUR recipe"
  git clone "$AUR_URL"
fi
cd packettracer

# 5. The PKGBUILD wants a specific filename next to it
EXPECTED="$(grep -oE "local://[^'\"[:space:])]+" PKGBUILD | head -1 | sed 's#^local://##')"
[[ -n "$EXPECTED" ]] || die "could not read the expected filename from the PKGBUILD"
if [[ "$(basename "$DEB")" != "$EXPECTED" ]]; then
  echo "warning: PKGBUILD expects '$EXPECTED' but you gave '$(basename "$DEB")'."
  echo "         Continuing; if the build fails, download the matching version."
fi
cp -f "$DEB" "./$EXPECTED"
rm -rf src pkg

# 6. Build and install (checksum skipped: Cisco re-uploads files under the same name)
info "Building package"
makepkg -si --skipchecksums

# 7. The package only ships an AppImage: add a launcher command, menu entry and pttp:// handler
[[ -x "$APPIMAGE" ]] || die "install finished but $APPIMAGE is missing"

mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"
cat > "$HOME/.local/bin/packettracer" << LAUNCH
#!/bin/sh
exec $APPIMAGE "\$@"
LAUNCH
chmod +x "$HOME/.local/bin/packettracer"

cat > "$HOME/.local/share/applications/packettracer.desktop" << DESKTOP
[Desktop Entry]
Name=Cisco Packet Tracer
Exec=$APPIMAGE %u
Type=Application
Categories=Education;Network;
Terminal=false
MimeType=x-scheme-handler/pttp;
DESKTOP
command -v update-desktop-database >/dev/null && update-desktop-database "$HOME/.local/share/applications" || true
xdg-mime default packettracer.desktop x-scheme-handler/pttp 2>/dev/null || true

case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) echo "note: add ~/.local/bin to your PATH to use the 'packettracer' command." ;;
esac

info "Done. Run 'packettracer' (type 2 to accept the EULA on first launch)."