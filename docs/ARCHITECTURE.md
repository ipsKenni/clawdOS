# Architecture

## Overview

clawdOS is a minimal Linux distribution where Claude Code CLI is the sole user interface. Built on Alpine Linux for a minimal footprint (~150-250MB ISO).

There is no desktop environment, no login prompt — the system boots directly into Claude Code. From there, you control the entire system: files, networking, packages, everything.

## Boot Sequence

```
BIOS/EFI → syslinux/GRUB → Linux Kernel (lts) → initramfs → OpenRC → clawdos-launcher → Claude Code
```

### Detailed Boot Flow

1. **Bootloader** loads kernel and initramfs from ISO/USB
2. **Kernel** initializes hardware, mounts root filesystem
3. **OpenRC** runs init scripts:
   - `sysinit`: Basic system setup
   - `boot`: Networking, hostname
   - `default`: dhcpcd, chronyd, sshd, claude-code service
4. **inittab** spawns processes on TTYs:
   - tty1: `clawdos-launcher` (respawn)
   - tty2: `clawdos-emergency` (respawn)
   - tty3: `tail -f /var/log/messages` (respawn)
5. **clawdos-launcher** checks first-boot status, runs setup wizard or starts Claude Code

## Filesystem Layout

```
/etc/clawdos/              Configuration directory
├── env                    Environment variables (API key, settings) [mode 0600]
├── configured             First-boot completion marker
└── emergency_pw           Hashed emergency shell password [mode 0600]

/usr/local/bin/            clawdOS scripts
├── clawdos-launcher       Main entry point (tty1)
├── clawdos-setup          First-boot wizard
└── clawdos-emergency      Emergency shell (tty2)

/mnt/persist/              Optional persistent storage mount
```

## TTY Layout

| TTY  | Access         | Function                          |
|------|----------------|-----------------------------------|
| tty1 | Default        | Claude Code (main UI)             |
| tty2 | Ctrl+Alt+F2    | Emergency shell (password-protected) |
| tty3 | Ctrl+Alt+F3    | Live system logs                  |

## Security Model

- **Single-user system**: Runs as root (single-purpose appliance design)
- **API key protection**: Stored in `/etc/clawdos/env` with mode `0600`
- **Emergency shell**: Password-protected with SHA-512 hash
- **Network**: DHCP by default, SSH available for remote access
- **Live system**: No persistent writes by default (ISO/RAM mode)

## Network

- Auto-configured via DHCP on all detected interfaces
- chronyd for NTP time sync
- SSH daemon enabled for remote management
- Claude Code requires outbound HTTPS to `api.anthropic.com`

## First Boot vs Subsequent Boots

### First Boot

1. Banner displayed on tty1
2. Setup wizard runs:
   - Anthropic API key
   - Timezone
   - Keyboard layout
   - Persistent storage (optional)
   - Emergency shell password
3. Claude Code installed from the internet
4. Configuration written to `/etc/clawdos/`
5. Claude Code launched

### Subsequent Boots

1. Banner displayed on tty1
2. Environment loaded from `/etc/clawdos/env`
3. Network connectivity verified
4. Claude Code launched directly

## Persistent Storage (Optional)

When configured during setup, a disk partition is mounted at `/mnt/persist`:

- `/mnt/persist/.clawdos-config/` — Configuration backup
- `/mnt/persist/home/` — User data
- Entry added to `/etc/fstab` for automatic mounting

Without persistent storage, the system runs entirely in RAM from the ISO. All changes are lost on reboot.

## Package Base

The ISO includes these Alpine packages:

- **Base**: alpine-base, openrc, busybox
- **Networking**: dhcpcd, chrony, openssh, ca-certificates
- **Claude Code deps**: bash, curl, libgcc, libstdc++, git, ripgrep
- **Tools**: nano, less, tmux, htop, sudo, e2fsprogs, parted
