# clawdOS

Alpine-based Linux distribution (~150-250MB) that boots directly into Claude Code. No desktop, no traditional shell — just Claude.

## Build

```bash
make iso          # Build ISO (requires Docker)
make test         # Run test suite (23 tests: overlay, shellcheck, build validation)
make lint         # Run shellcheck on all scripts
make qemu         # Boot ISO headless (serial console)
make qemu-gui     # Boot ISO with display
```

## Project Structure

```
build/                      # ISO build pipeline
  mkimg.clawdos.sh          # Alpine mkimage profile (package list)
  genapkovl-clawdos.sh      # Overlay generator (copies rootfs into ISO)
  build.sh                  # Docker entrypoint for ISO build
  Dockerfile                # Builder container

rootfs/                     # Files overlaid onto the ISO filesystem
  etc/inittab               # TTY assignments (tty1=Claude, tty2=emergency, tty3=logs)
  etc/init.d/claude-code    # OpenRC service
  etc/conf.d/claude-code    # OpenRC service config
  etc/local.d/claude-setup.start  # First-boot trigger
  etc/profile.d/clawdos.sh  # Shell environment (CLAWDOS_VERSION, PATH)
  etc/network/interfaces    # DHCP network config
  etc/motd                  # Login banner
  usr/local/bin/
    clawdos-launcher        # Main entry: setup → Claude Code loop
    clawdos-setup           # First-boot wizard (API key, password, Claude install)
    clawdos-emergency       # Password-protected rescue shell on tty2
    clawdos-boot-animation  # Terminal boot splash

tests/                      # Test suite (bash, run via `make test`)
docs/                       # Documentation
```

## Code Style

- All scripts are POSIX-ish bash (`#!/bin/bash`, `set -euo pipefail`)
- Must pass `shellcheck -x` (config in `.shellcheckrc`)
- No external dependencies beyond Alpine base + packages in `mkimg.clawdos.sh`
- Scripts in `rootfs/usr/local/bin/` have no `.sh` extension and must be executable

## Key Design Decisions

- tty1 runs Claude Code (via `clawdos-launcher` from inittab, respawning)
- tty2 runs emergency shell (password-protected, for manual recovery)
- tty3 tails `/var/log/messages` for debugging
- First-boot detection: presence of `/etc/clawdos/setup_done`
- API key stored in `/etc/clawdos/api_key`
- Emergency password hash in `/etc/clawdos/emergency_pw`
