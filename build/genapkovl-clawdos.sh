#!/bin/sh
# genapkovl-clawdos.sh - Generate clawdOS APK overlay
# This is the core of the clawdOS customization.
# It takes all files from rootfs/ and packages them into the overlay.

set -e

HOSTNAME="clawdos"

cleanup() {
    rm -rf "$tmp"
}

tmp="$(mktemp -d)"
trap cleanup EXIT

# Get the rootfs directory (passed as argument or relative to script)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOTFS_DIR="${ROOTFS_DIR:-$SCRIPT_DIR/../rootfs}"

# Create base directory structure
mkdir -p "$tmp"/etc
mkdir -p "$tmp"/etc/clawdos
mkdir -p "$tmp"/etc/conf.d
mkdir -p "$tmp"/etc/init.d
mkdir -p "$tmp"/etc/local.d
mkdir -p "$tmp"/etc/network
mkdir -p "$tmp"/etc/profile.d
mkdir -p "$tmp"/etc/runlevels/default
mkdir -p "$tmp"/etc/runlevels/boot
mkdir -p "$tmp"/usr/local/bin

# Set hostname
echo "$HOSTNAME" > "$tmp"/etc/hostname

# Copy rootfs overlay files
if [ -d "$ROOTFS_DIR" ]; then
    cp -a "$ROOTFS_DIR"/* "$tmp"/
else
    echo "ERROR: rootfs directory not found at $ROOTFS_DIR" >&2
    exit 1
fi

# Set executable permissions on scripts
chmod 755 "$tmp"/usr/local/bin/clawdos-launcher
chmod 755 "$tmp"/usr/local/bin/clawdos-setup
chmod 755 "$tmp"/usr/local/bin/clawdos-emergency
chmod 755 "$tmp"/usr/local/bin/clawdos-boot-animation
chmod 755 "$tmp"/etc/init.d/claude-code
chmod 755 "$tmp"/etc/local.d/claude-setup.start

# Enable services in runlevels
# Boot runlevel
ln -sf /etc/init.d/networking "$tmp"/etc/runlevels/boot/networking
ln -sf /etc/init.d/hostname "$tmp"/etc/runlevels/boot/hostname

# Default runlevel
ln -sf /etc/init.d/dhcpcd "$tmp"/etc/runlevels/default/dhcpcd
ln -sf /etc/init.d/chronyd "$tmp"/etc/runlevels/default/chronyd
ln -sf /etc/init.d/sshd "$tmp"/etc/runlevels/default/sshd
ln -sf /etc/init.d/claude-code "$tmp"/etc/runlevels/default/claude-code
ln -sf /etc/init.d/local "$tmp"/etc/runlevels/default/local

# Create the overlay tarball
tar -czf "$HOSTNAME.apkovl.tar.gz" -C "$tmp" .

echo "Overlay created: $HOSTNAME.apkovl.tar.gz"
