#!/bin/bash
# Test: All shell scripts pass shellcheck
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

PASS=0
FAIL=0
ERRORS=""

echo "=== ShellCheck Lint Test ==="
echo ""

# Find all shell scripts
scripts=()

# Scripts in build/
for f in "$PROJECT_DIR"/build/*.sh; do
    [ -f "$f" ] && scripts+=("$f")
done

# Scripts in rootfs/usr/local/bin/
for f in "$PROJECT_DIR"/rootfs/usr/local/bin/*; do
    [ -f "$f" ] && scripts+=("$f")
done

# Scripts in rootfs/etc/local.d/
for f in "$PROJECT_DIR"/rootfs/etc/local.d/*.start; do
    [ -f "$f" ] && scripts+=("$f")
done

# Scripts in rootfs/etc/profile.d/
for f in "$PROJECT_DIR"/rootfs/etc/profile.d/*.sh; do
    [ -f "$f" ] && scripts+=("$f")
done

# Test scripts themselves
for f in "$PROJECT_DIR"/tests/*.sh; do
    [ -f "$f" ] && scripts+=("$f")
done

if [ ${#scripts[@]} -eq 0 ]; then
    echo "FAIL: No scripts found to check"
    exit 1
fi

for script in "${scripts[@]}"; do
    name="${script#"$PROJECT_DIR"/}"
    if shellcheck -x "$script" 2>&1; then
        echo "  PASS: $name"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $name"
        FAIL=$((FAIL + 1))
        ERRORS="$ERRORS\n  - $name"
    fi
done

echo ""
echo "Results: $PASS passed, $FAIL failed"

if [ $FAIL -gt 0 ]; then
    echo -e "Failed scripts:$ERRORS"
    exit 1
fi

echo "All scripts pass shellcheck!"
