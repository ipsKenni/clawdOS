#!/bin/bash
# Test: Validate built ISO file
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="${OUTPUT_DIR:-$PROJECT_DIR/output}"

PASS=0
FAIL=0

echo "=== ISO Build Validation Test ==="
echo ""

# Find ISO file
ISO_FILE=$(find "$OUTPUT_DIR" -name "*.iso" -type f 2>/dev/null | head -1)

if [ -z "$ISO_FILE" ]; then
    echo "SKIP: No ISO file found in $OUTPUT_DIR"
    echo "Run 'make iso' first to build the ISO."
    exit 0
fi

echo "Testing: $ISO_FILE"
echo ""

# Test: File exists and is not empty
if [ -s "$ISO_FILE" ]; then
    echo "  PASS: ISO file exists and is not empty"
    PASS=$((PASS + 1))
else
    echo "  FAIL: ISO file is empty"
    FAIL=$((FAIL + 1))
fi

# Test: File size in expected range (100MB - 500MB)
ISO_SIZE=$(stat -c%s "$ISO_FILE" 2>/dev/null || stat -f%z "$ISO_FILE" 2>/dev/null)
ISO_SIZE_MB=$((ISO_SIZE / 1024 / 1024))
if [ "$ISO_SIZE_MB" -ge 100 ] && [ "$ISO_SIZE_MB" -le 500 ]; then
    echo "  PASS: ISO size is ${ISO_SIZE_MB}MB (expected 100-500MB)"
    PASS=$((PASS + 1))
else
    echo "  FAIL: ISO size is ${ISO_SIZE_MB}MB (expected 100-500MB)"
    FAIL=$((FAIL + 1))
fi

# Test: Valid ISO format (check for ISO9660 magic)
if file "$ISO_FILE" | grep -qi "iso 9660\|DOS/MBR boot"; then
    echo "  PASS: Valid ISO format detected"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Not a valid ISO format"
    FAIL=$((FAIL + 1))
fi

# Test: SHA256 checksum file exists
SHA_FILE="${ISO_FILE}.sha256"
if [ -f "$SHA_FILE" ]; then
    echo "  PASS: SHA256 checksum file exists"
    PASS=$((PASS + 1))

    # Verify checksum
    cd "$(dirname "$ISO_FILE")"
    if sha256sum -c "$(basename "$SHA_FILE")" >/dev/null 2>&1; then
        echo "  PASS: SHA256 checksum matches"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: SHA256 checksum mismatch"
        FAIL=$((FAIL + 1))
    fi
else
    echo "  SKIP: No SHA256 checksum file"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"

if [ $FAIL -gt 0 ]; then
    exit 1
fi

echo "ISO validation passed!"
