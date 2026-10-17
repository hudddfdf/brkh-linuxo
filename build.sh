#!/usr/bin/env bash
# Run this on your Arch Linux VM as root

set -e

PROFILE_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="$PROFILE_DIR/out"

echo "[*] Installing archiso if needed..."
pacman -S --noconfirm archiso

echo "[*] Adding BlackArch keyring..."
curl -O https://blackarch.org/strap.sh
chmod +x strap.sh
./strap.sh
rm strap.sh

echo "[*] Building brkh linux ISO..."
mkdir -p "$OUT_DIR"
mkarchiso -v -w /tmp/brkh-work -o "$OUT_DIR" "$PROFILE_DIR"

echo ""
echo "[+] Done! ISO saved to: $OUT_DIR"
ls -lh "$OUT_DIR"/*.iso
