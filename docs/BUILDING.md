# Building clawdOS

## Prerequisites

- Docker (19.03+)
- GNU Make
- ~2GB disk space for build
- Internet connection (to download Alpine packages)

## Quick Build

```bash
make iso
```

This will:

1. Build the Docker build environment (Alpine + build tools)
2. Run the ISO build inside the container
3. Output the ISO to `output/clawdos-<version>-x86_64.iso`

## Step by Step

### 1. Build Environment

```bash
make docker-build-env
```

Creates a Docker image with Alpine SDK, syslinux, xorriso, and other build tools.

### 2. Build ISO

```bash
make iso
```

Runs `build/build.sh` inside the Docker container, which:

- Copies the mkimage profile into Alpine's aports
- Runs `mkimage.sh` to create the ISO
- Generates SHA-256 checksums

### 3. Test

```bash
make test    # Run all tests
make lint    # ShellCheck only
```

### 4. Run in QEMU

```bash
make qemu        # Headless (serial console)
make qemu-gui    # With display window
```

## Build Configuration

### Custom Version

```bash
VERSION=1.0.0 make iso
```

### Custom Output Directory

```bash
OUTPUT_DIR=/tmp/build make iso
```

## Build System Architecture

```
build/
├── Dockerfile              Build environment definition
├── mkimg.clawdos.sh        Alpine mkimage profile (packages, kernel, format)
├── genapkovl-clawdos.sh    Overlay generator (packages rootfs/ into apkovl)
└── build.sh                Build orchestrator
```

### Overlay Generator (genapkovl-clawdos.sh)

This is the core of the build. It:

1. Creates a temporary directory with the overlay structure
2. Copies all files from `rootfs/` into it
3. Sets correct permissions on executables
4. Creates symlinks for OpenRC service runlevels
5. Packages everything as a `.apkovl.tar.gz`

The overlay is applied by Alpine's initramfs at boot time, overlaying the base system with clawdOS customizations.

## Customization

### Adding Packages

Edit `build/mkimg.clawdos.sh` and add packages to the `apks` variable.

### Adding Files to the Image

Place files in `rootfs/` maintaining the full path structure. For example, to add a script at `/usr/local/bin/myscript`, create `rootfs/usr/local/bin/myscript`.

### Adding OpenRC Services

1. Create the service script in `rootfs/etc/init.d/`
2. Add a symlink in `build/genapkovl-clawdos.sh` to enable it in the appropriate runlevel

## Troubleshooting

### Build fails with permission errors

Ensure Docker is running and your user is in the `docker` group:

```bash
sudo usermod -aG docker $USER
```

### ISO too large

Review packages in `build/mkimg.clawdos.sh` and remove unnecessary ones. Target size is 150-250MB.

### Overlay not applied at boot

Verify `build/genapkovl-clawdos.sh` is executable and the rootfs structure is correct:

```bash
make test
```
