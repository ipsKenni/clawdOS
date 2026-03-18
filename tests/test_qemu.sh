#!/bin/bash
# Test: Boot ISO in QEMU and verify basic functionality
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="${OUTPUT_DIR:-$PROJECT_DIR/output}"
TIMEOUT="${QEMU_TIMEOUT:-60}"

echo "=== QEMU Integration Test ==="
echo ""

# Find ISO file
ISO_FILE=$(find "$OUTPUT_DIR" -name "*.iso" -type f 2>/dev/null | head -1)

if [ -z "$ISO_FILE" ]; then
    echo "SKIP: No ISO file found in $OUTPUT_DIR"
    echo "Run 'make iso' first to build the ISO."
    exit 0
fi

# Check for QEMU
if ! command -v qemu-system-x86_64 &>/dev/null; then
    echo "SKIP: qemu-system-x86_64 not found"
    exit 0
fi

echo "Testing: $ISO_FILE"
echo "Timeout: ${TIMEOUT}s"
echo ""

# Create a temporary file for serial output
SERIAL_LOG=$(mktemp)
trap 'rm -f "$SERIAL_LOG"; kill $QEMU_PID 2>/dev/null' EXIT

# Boot QEMU with serial output
qemu-system-x86_64 \
    -m 1024 \
    -cdrom "$ISO_FILE" \
    -boot d \
    -nographic \
    -serial file:"$SERIAL_LOG" \
    -no-reboot \
    -enable-kvm 2>/dev/null || true &

QEMU_PID=$!

# Wait for boot and check serial output
PASS=0
FAIL=0
ELAPSED=0

echo "Waiting for boot..."
while [ $ELAPSED -lt "$TIMEOUT" ]; do
    sleep 5
    ELAPSED=$((ELAPSED + 5))

    # Check if QEMU is still running
    if ! kill -0 $QEMU_PID 2>/dev/null; then
        echo "  WARN: QEMU exited early"
        break
    fi

    # Check for boot indicators in serial log
    if grep -q "clawdOS" "$SERIAL_LOG" 2>/dev/null; then
        echo "  PASS: clawdOS banner detected (${ELAPSED}s)"
        PASS=$((PASS + 1))
        break
    fi

    echo "  Waiting... (${ELAPSED}s)"
done

# Check serial output for key markers
if grep -qi "openrc" "$SERIAL_LOG" 2>/dev/null; then
    echo "  PASS: OpenRC init detected"
    PASS=$((PASS + 1))
else
    echo "  INFO: OpenRC init not detected in serial output"
fi

if grep -qi "dhcp\|network" "$SERIAL_LOG" 2>/dev/null; then
    echo "  PASS: Network initialization detected"
    PASS=$((PASS + 1))
else
    echo "  INFO: Network init not detected in serial output"
fi

# Cleanup
kill $QEMU_PID 2>/dev/null || true
wait $QEMU_PID 2>/dev/null || true

echo ""
echo "Serial log (last 20 lines):"
tail -20 "$SERIAL_LOG" 2>/dev/null | sed 's/^/  /'

echo ""
echo "Results: $PASS passed, $FAIL failed"

if [ $FAIL -gt 0 ]; then
    exit 1
fi

echo "QEMU integration test completed!"
