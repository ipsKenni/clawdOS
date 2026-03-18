#!/bin/sh
# clawdOS ISO Build Orchestrator
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APORTS_DIR="$HOME/aports"
OUTPUT_DIR="${OUTPUT_DIR:-$PROJECT_DIR/output}"
VERSION="${VERSION:-dev}"

echo "=== clawdOS ISO Builder ==="
echo "Version: $VERSION"
echo ""

# Step 1: Copy mkimage profile to aports
echo "[1/4] Installing mkimage profile..."
cp "$SCRIPT_DIR/mkimg.clawdos.sh" "$APORTS_DIR/scripts/"

# Step 2: Copy and prepare overlay generator
echo "[2/4] Preparing overlay generator..."
cp "$SCRIPT_DIR/genapkovl-clawdos.sh" "$APORTS_DIR/scripts/"
chmod +x "$APORTS_DIR/scripts/genapkovl-clawdos.sh"

# Export ROOTFS_DIR so the overlay generator can find our rootfs
export ROOTFS_DIR="$PROJECT_DIR/rootfs"

# Step 3: Build the ISO
echo "[3/4] Building ISO..."
cd "$APORTS_DIR/scripts"

sh mkimage.sh \
    --tag "v$VERSION" \
    --outdir "$OUTPUT_DIR" \
    --arch x86_64 \
    --repository "https://dl-cdn.alpinelinux.org/alpine/v3.21/main" \
    --repository "https://dl-cdn.alpinelinux.org/alpine/v3.21/community" \
    --profile clawdos

# Step 4: Rename and checksum
echo "[4/4] Finalizing..."
cd "$OUTPUT_DIR"

# Find the generated ISO
ISO_FILE=$(find . -maxdepth 1 -name 'alpine-clawdos-*.iso' -print -quit)
if [ -z "$ISO_FILE" ]; then
    echo "ERROR: No ISO file found in $OUTPUT_DIR" >&2
    exit 1
fi

FINAL_NAME="clawdos-${VERSION}-x86_64.iso"
mv "$ISO_FILE" "$FINAL_NAME"

# Generate checksums
sha256sum "$FINAL_NAME" > "$FINAL_NAME.sha256"

echo ""
echo "=== Build Complete ==="
echo "ISO: $OUTPUT_DIR/$FINAL_NAME"
echo "SHA: $OUTPUT_DIR/$FINAL_NAME.sha256"
echo "Size: $(du -h "$FINAL_NAME" | cut -f1)"
