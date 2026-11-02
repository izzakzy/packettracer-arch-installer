#!/usr/bin/env bash
set -euo pipefail
sudo pacman -Rns packettracer
rm -f "$HOME/.local/bin/packettracer" "$HOME/.local/share/applications/packettracer.desktop"
rm -rf "${XDG_CACHE_HOME:-$HOME/.cache}/packettracer-install"
echo "Packet Tracer removed."