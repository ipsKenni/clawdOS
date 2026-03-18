# Using clawdOS

## Getting Started

### Boot from ISO

1. Download the latest ISO from [Releases](../../releases)
2. Boot in your preferred VM:
   - **QEMU**: `qemu-system-x86_64 -m 1024 -cdrom clawdos.iso -boot d`
   - **VirtualBox**: Create new VM → Linux/Other Linux (64-bit) → attach ISO
   - **VMware**: Create new VM → attach ISO as CD/DVD
3. The system boots directly to the clawdOS setup wizard

### First Boot Setup

The setup wizard guides you through:

1. **API Key** — Enter your Anthropic API key (get one at https://console.anthropic.com/settings/keys)
2. **Timezone** — Set your timezone (e.g., `UTC`, `Europe/Berlin`, `America/New_York`)
3. **Keyboard Layout** — Choose your layout (e.g., `us`, `de`, `fr`)
4. **Persistent Storage** — Optionally configure a disk for data that survives reboots
5. **Emergency Password** — Set a password for the rescue shell on tty2

After setup, Claude Code is installed and launched automatically.

## Daily Use

### Claude Code (tty1)

This is your main interface. Claude Code has full system access and can:

- Manage files and directories
- Install and configure software
- Monitor system resources
- Configure networking
- Run any system command
- Edit configuration files

If Claude Code exits, it automatically restarts after 3 seconds.

### Emergency Shell (tty2)

Access with **Ctrl+Alt+F2**. This is a password-protected ash shell for when Claude Code isn't working.

Use this to:

- Debug network issues
- Check system logs
- Manually edit configuration
- Restart services
- Install packages manually

Type `exit` to return to the login prompt.

### System Logs (tty3)

Access with **Ctrl+Alt+F3**. Live view of `/var/log/messages`.

Return to Claude Code with **Ctrl+Alt+F1**.

## Configuration

### Environment Variables

Stored in `/etc/clawdos/env` (mode 0600):

| Variable | Description |
|----------|-------------|
| `ANTHROPIC_API_KEY` | Your Anthropic API key |
| `CLAWDOS_TIMEZONE` | Configured timezone |
| `CLAWDOS_KEYMAP` | Keyboard layout |
| `CLAWDOS_PERSIST_DEV` | Persistent storage device (if configured) |

### Changing API Key

Edit `/etc/clawdos/env` and update `ANTHROPIC_API_KEY`. Claude Code will pick up the change on next restart (it auto-restarts when exited).

### Re-running Setup

Delete the configuration marker to trigger the setup wizard:

```sh
rm /etc/clawdos/configured
```

Claude Code will restart and the setup wizard will run again.

## Persistent Storage

By default, clawdOS runs from the ISO in RAM. All changes are lost on reboot.

To persist data, configure a disk during first-boot setup, or manually from the emergency shell:

```sh
mkfs.ext4 /dev/sda1
mkdir -p /mnt/persist
mount /dev/sda1 /mnt/persist
echo "/dev/sda1 /mnt/persist ext4 defaults,noatime 0 2" >> /etc/fstab
```

## Installing to Disk

clawdOS can be installed permanently to a disk. From the emergency shell:

```sh
setup-disk /dev/sda
```

This uses Alpine's standard disk installation tool.

## Networking

- **Ethernet**: Auto-configured via DHCP
- **WiFi**: Requires manual configuration in the emergency shell
- **SSH**: Enabled by default (set a root password in the emergency shell first)

## Troubleshooting

### Claude Code won't start

1. Check network: switch to tty2, run `ping api.anthropic.com`
2. Check API key: `cat /etc/clawdos/env`
3. Reinstall: `curl -fsSL https://claude.ai/install.sh | bash`

### No network

1. Switch to tty2 (Ctrl+Alt+F2)
2. Check interfaces: `ip addr`
3. Restart networking: `rc-service networking restart`
4. Restart DHCP: `rc-service dhcpcd restart`

### System feels slow

Check resources in the emergency shell:

```sh
htop
free -h
df -h
```

### Factory Reset

Remove all clawdOS configuration to start fresh:

```sh
rm -rf /etc/clawdos/*
```

The setup wizard will run on the next Claude Code restart.
