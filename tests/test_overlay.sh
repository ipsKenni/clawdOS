#!/bin/bash
# Test: Overlay contains all required files and structure
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

PASS=0
FAIL=0

echo "=== Overlay Structure Test ==="
echo ""

assert_file() {
    local file="$1"
    local desc="${2:-$1}"
    if [ -f "$PROJECT_DIR/rootfs/$file" ]; then
        echo "  PASS: $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $desc (missing: rootfs/$file)"
        FAIL=$((FAIL + 1))
    fi
}

assert_executable() {
    local file="$1"
    local desc="${2:-$1}"
    if [ -f "$PROJECT_DIR/rootfs/$file" ] && [ -x "$PROJECT_DIR/rootfs/$file" ]; then
        echo "  PASS: $desc (executable)"
        PASS=$((PASS + 1))
    elif [ -f "$PROJECT_DIR/rootfs/$file" ]; then
        echo "  FAIL: $desc (exists but not executable)"
        FAIL=$((FAIL + 1))
    else
        echo "  FAIL: $desc (missing: rootfs/$file)"
        FAIL=$((FAIL + 1))
    fi
}

assert_contains() {
    local file="$1"
    local pattern="$2"
    local desc="$3"
    if [ -f "$PROJECT_DIR/rootfs/$file" ] && grep -q "$pattern" "$PROJECT_DIR/rootfs/$file"; then
        echo "  PASS: $desc"
        PASS=$((PASS + 1))
    else
        echo "  FAIL: $desc"
        FAIL=$((FAIL + 1))
    fi
}

echo "--- Required Files ---"
assert_file "etc/inittab" "inittab exists"
assert_file "etc/motd" "motd banner exists"
assert_file "etc/conf.d/claude-code" "OpenRC config exists"
assert_file "etc/network/interfaces" "Network config exists"
assert_file "etc/profile.d/clawdos.sh" "Profile script exists"

echo ""
echo "--- Executable Scripts ---"
assert_executable "usr/local/bin/clawdos-launcher" "Launcher"
assert_executable "usr/local/bin/clawdos-setup" "Setup wizard"
assert_executable "usr/local/bin/clawdos-emergency" "Emergency shell"
assert_executable "usr/local/bin/clawdos-boot-animation" "Boot animation"
assert_executable "etc/init.d/claude-code" "OpenRC service"
assert_executable "etc/local.d/claude-setup.start" "Local.d setup"

echo ""
echo "--- Content Validation ---"
assert_contains "etc/inittab" "clawdos-launcher" "inittab references launcher"
assert_contains "etc/inittab" "clawdos-emergency" "inittab references emergency shell"
assert_contains "etc/inittab" "tty3.*tail" "inittab has log viewer on tty3"
assert_contains "etc/init.d/claude-code" "openrc-run" "Service uses openrc-run"
assert_contains "etc/init.d/claude-code" "need net" "Service depends on network"
assert_contains "etc/profile.d/clawdos.sh" "CLAWDOS_VERSION" "Profile sets version"
assert_contains "usr/local/bin/clawdos-launcher" "clawdos-setup" "Launcher calls setup"
assert_contains "usr/local/bin/clawdos-setup" "ANTHROPIC_API_KEY" "Setup configures API key"
assert_contains "usr/local/bin/clawdos-setup" "claude.ai/install.sh" "Setup installs Claude Code"
assert_contains "etc/network/interfaces" "dhcp" "Network uses DHCP"

echo ""
echo "--- Build Scripts ---"
if [ -f "$PROJECT_DIR/build/genapkovl-clawdos.sh" ] && [ -x "$PROJECT_DIR/build/genapkovl-clawdos.sh" ]; then
    echo "  PASS: Overlay generator is executable"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Overlay generator missing or not executable"
    FAIL=$((FAIL + 1))
fi

if [ -f "$PROJECT_DIR/build/build.sh" ] && [ -x "$PROJECT_DIR/build/build.sh" ]; then
    echo "  PASS: Build script is executable"
    PASS=$((PASS + 1))
else
    echo "  FAIL: Build script missing or not executable"
    FAIL=$((FAIL + 1))
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"

if [ $FAIL -gt 0 ]; then
    exit 1
fi

echo "All overlay structure tests passed!"
