#!/usr/bin/env bash
# Compare the installed Packet Tracer with the version in the AUR.
set -euo pipefail

installed="$(pacman -Q packettracer 2>/dev/null | awk '{print $2}' || true)"
aur="$(curl -fsS "https://aur.archlinux.org/rpc/?v=5&type=info&arg[]=packettracer" \
        | grep -o '"Version":"[^"]*"' | cut -d'"' -f4 || true)"

echo "Installed: ${installed:-not installed}"
echo "AUR:       ${aur:-unknown (could not reach the AUR)}"

if [[ -n "$installed" && -n "$aur" && "$installed" != "$aur" ]]; then
  echo
  echo "A newer package is available. Download the matching .deb from Cisco, then run:"
  echo "  ./install.sh ~/Downloads/CiscoPacketTracer_<version>_Ubuntu_64bit.deb"
else
  echo
  echo "Also compare with the version shown on Cisco's download page (skillsforall.com)."
fi