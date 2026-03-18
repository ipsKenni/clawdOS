# clawdOS Installation Guide

This guide covers installing and running clawdOS on Proxmox VE and on bare metal hardware.

---

## Proxmox VE Installation

### 1. Upload the ISO

Copy the clawdOS ISO to Proxmox's template storage:

```bash
scp clawdos-*.iso root@proxmox:/var/lib/vz/template/iso/
```

Or upload via the Proxmox Web UI: **Datacenter → Storage → ISO Images → Upload**.

### 2. Create a VM

In the Proxmox Web UI (**Create VM**):

| Setting | Recommended Value |
|---------|-------------------|
| **OS Type** | Linux, Kernel 6.x - 2.6 |
| **ISO Image** | `clawdos-*.iso` |
| **CPU** | 1-2 cores |
| **RAM** | 1-2 GB (512 MB minimum) |
| **Disk** | 8-32 GB (optional, only needed for persistent installation) |
| **Network** | vmbr0 (Bridge), Model: VirtIO |
| **Display** | Default (VNC) or Serial Console |

> **Tip:** For a purely live (RAM-only) setup you can skip adding a disk entirely. clawdOS runs from the ISO image.

### 3. Boot Configuration

- Set **CD/DVD** as the primary boot device.
- The VM will boot into the clawdOS first-boot wizard automatically.

#### Optional: Install to Disk

After booting, open the Emergency Shell (`Ctrl+Alt+F2`) and run:

```bash
setup-disk /dev/sda
```

This installs clawdOS persistently so configuration and data survive reboots.

#### Serial Console (headless)

For headless operation, enable a serial console on the VM:

```bash
qm set <vmid> -serial0 socket
```

Then connect via the Proxmox UI (**Console → xterm.js**) or:

```bash
qm terminal <vmid>
```

### 4. Cloud-Init / Automation (Optional)

You can pre-configure the API key via Cloud-Init userdata to skip the first-boot wizard:

```yaml
#cloud-config
write_files:
  - path: /etc/clawdos/api_key
    content: "sk-ant-..."
    permissions: "0600"
  - path: /etc/clawdos/setup_done
    content: ""
```

> **Note:** clawdOS has its own first-boot setup wizard. Cloud-Init is purely optional for automated deployments.

### 5. Proxmox-Specific Tips

- **VirtIO drivers** are already included in the Alpine kernel — no extra setup needed.
- **Backups:** Use `vzdump` to back up the VM as with any other Proxmox VM.
- **Snapshots:** Take Proxmox snapshots before major changes. Works well with clawdOS since the OS footprint is small.
- **Resource tuning:** clawdOS is lightweight. Start with 1 core / 1 GB RAM and scale up only if Claude Code workloads require it.

---

## Bare Metal Installation

### 1. Write the ISO to USB

#### Linux

```bash
dd if=clawdos.iso of=/dev/sdX bs=4M status=progress
sync
```

> Replace `/dev/sdX` with your USB device. Use `lsblk` to identify it. **All data on the target device will be erased.**

#### macOS

```bash
diskutil unmountDisk /dev/diskN
sudo dd if=clawdos.iso of=/dev/rdiskN bs=4m
sync
```

#### Windows

Use [Rufus](https://rufus.ie/) or [balenaEtcher](https://etcher.balena.io/):

1. Select the clawdOS ISO
2. Select the target USB drive
3. Click **Start** / **Flash**

#### Ventoy

If you use [Ventoy](https://www.ventoy.net/), simply copy `clawdos.iso` to the Ventoy USB partition. Select it from the Ventoy boot menu.

### 2. BIOS / UEFI Setup

1. Enter your firmware setup (usually `F2`, `F12`, `Del`, or `Esc` at boot).
2. Set the USB drive as the primary boot device.
3. **Secure Boot:** Disable it if enabled. Alpine Linux does not ship signed bootloaders for Secure Boot.
4. **Legacy / CSM Mode:** If UEFI boot fails, try enabling CSM (Compatibility Support Module) or Legacy mode.

### 3. Live Mode vs. Disk Installation

#### Live Mode (Default)

clawdOS runs entirely in RAM from the USB stick. Nothing is written to the internal disk. Configuration is **not persistent** — it resets on reboot.

This is useful for:
- Quick testing
- Ephemeral environments
- Machines where you don't want to modify the disk

#### Disk Installation

For a persistent setup, open the Emergency Shell (`Ctrl+Alt+F2`) and run:

```bash
setup-disk /dev/sda
```

Or manually:

```bash
# Partition the disk
fdisk /dev/sda
# (create a single Linux partition)

# Format
mkfs.ext4 /dev/sda1

# Mount and install
mount /dev/sda1 /mnt
setup-disk -m sys /mnt
```

After installation, remove the USB stick and reboot. The bootloader (syslinux or GRUB) is installed automatically.

### 4. Hardware Compatibility

| Component | Support |
|-----------|---------|
| **CPU** | x86_64 required |
| **RAM** | 512 MB minimum, 1 GB+ recommended |
| **Ethernet** | Most Intel and Realtek NICs work out of the box (Alpine kernel drivers) |
| **WiFi** | Requires manual configuration (see below) |
| **GPU** | Not relevant — clawdOS is headless / TTY-only |
| **Storage** | SATA, NVMe, USB, eMMC, SD cards |

### 5. Network Configuration on Bare Metal

#### Ethernet (Default)

Ethernet is configured for DHCP automatically. No action needed if your network has a DHCP server.

#### Static IP

Edit `/etc/network/interfaces`:

```
auto eth0
iface eth0 inet static
    address 192.168.1.100/24
    gateway 192.168.1.1
```

Then restart networking:

```bash
rc-service networking restart
```

#### WiFi

WiFi requires additional packages and manual configuration:

```bash
apk add wpa_supplicant wireless-tools
```

Create `/etc/wpa_supplicant/wpa_supplicant.conf`:

```
network={
    ssid="YourNetwork"
    psk="YourPassword"
}
```

Enable and start:

```bash
rc-update add wpa_supplicant boot
rc-service wpa_supplicant start
```

Add to `/etc/network/interfaces`:

```
auto wlan0
iface wlan0 inet dhcp
```

### 6. After Installation

- **Bootloader:** Automatically installed by `setup-disk` (syslinux for BIOS, GRUB for UEFI).
- **API key and config:** Stored persistently on disk under `/etc/clawdos/`.
- **System updates:**
  ```bash
  apk update && apk upgrade
  ```
- **Adding packages:** The Emergency Shell (`Ctrl+Alt+F2`) gives you a standard Alpine shell where you can run `apk add <package>`.
