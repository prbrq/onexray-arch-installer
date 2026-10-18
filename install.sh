#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

if ! command -v pacman >/dev/null || ! command -v makepkg >/dev/null; then
  echo "error: this installer targets Arch-based distributions (pacman + makepkg)" >&2
  exit 1
fi

if pacman -Q base-devel >/dev/null 2>&1; then
  :
else
  echo "error: install the base-devel group first: sudo pacman -S --needed base-devel" >&2
  exit 1
fi

if pgrep -x OneXray >/dev/null 2>&1; then
  echo "warning: OneXray is running. Quit it (tray -> Quit) before the install finishes"
  echo "         so the VPN core is restarted from the packaged files."
  echo
fi

# -s: install missing dependencies, -i: install the built package
exec makepkg -si --noconfirm
