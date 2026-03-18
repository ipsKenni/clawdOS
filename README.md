```
      _                     _  ___  ____
  ___| | __ ___      __ __| |/ _ \/ ___|
 / __| |/ _` \ \ /\ / / _` | | | \___ \
| (__| | (_| |\ V  V / (_| | |_| |___) |
 \___|_|\__,_| \_/\_/ \__,_|\___/|____/
```

# clawdOS

**A minimal Linux OS where Claude Code is the only user interface.**

clawdOS is an Alpine-based Linux distribution (~150-250MB) that boots directly into Claude Code. No desktop environment, no traditional shell — just you and Claude.

## Features

- **Boots to Claude Code** — Claude Code launches as the primary (and only) user interface
- **Alpine-based** — Minimal footprint at ~150-250MB ISO size
- **First-boot wizard** — Interactive setup for API keys and basic configuration
- **Emergency shell** — Escape hatch via `Ctrl+Alt+F2` for manual recovery
- **Persistent storage support** — Save configuration and data across reboots
- **Proxmox & Bare Metal ready** — Runs as a VM or directly on hardware

## Quick Start

```bash
make iso
```

Then boot the resulting ISO in your preferred VM (QEMU, VirtualBox, etc.):

```bash
make qemu       # headless, serial console
make qemu-gui   # with graphical display
```

## Requirements

- **Docker** — Used to build the ISO in a reproducible environment
- **make** — GNU Make for build orchestration

## Documentation

- [Installation Guide](docs/INSTALLATION.md) — Proxmox VE & Bare Metal
- [Architecture Overview](docs/ARCHITECTURE.md)
- [Building from Source](docs/BUILDING.md)
- [Usage Guide](docs/USAGE.md)

## License

[MIT](LICENSE)
