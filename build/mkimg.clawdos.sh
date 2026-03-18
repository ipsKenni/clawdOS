profile_clawdos() {
    profile_standard
    title="clawdOS"
    desc="clawdOS - Claude Code as your OS"
    arch="x86_64"
    output_format="iso"
    image_ext="iso"
    kernel_flavors="lts"
    kernel_addons=""
    boot_addons=""
    initfs_features="ata base cdrom ext4 mmc nvme scsi squashfs usb"
    apkovl="genapkovl-clawdos.sh"

    # Base system packages
    apks="$apks
        alpine-base
        openrc
        busybox
    "

    # Networking
    apks="$apks
        dhcpcd
        chrony
        openssh
        ca-certificates
    "

    # Required for Claude Code
    apks="$apks
        bash
        curl
        libgcc
        libstdc++
        git
        ripgrep
    "

    # Useful tools
    apks="$apks
        nano
        less
        tmux
        htop
        sudo
        bc
        e2fsprogs
        parted
        lsblk
        util-linux
        shadow
    "
}
