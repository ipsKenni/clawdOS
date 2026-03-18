FROM alpine:3.21

# Install build dependencies
RUN apk add --no-cache \
    alpine-sdk \
    build-base \
    apk-tools \
    alpine-conf \
    busybox \
    fakeroot \
    syslinux \
    xorriso \
    squashfs-tools \
    grub \
    grub-efi \
    mtools \
    dosfstools \
    abuild \
    sudo \
    git

# Create build user
RUN adduser -D builder && \
    addgroup builder abuild && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Setup abuild key
RUN su - builder -c "abuild-keygen -a -n"

# Clone aports for mkimage
RUN git clone --depth=1 --branch=v3.21.0 https://gitlab.alpinelinux.org/alpine/aports.git /home/builder/aports && \
    chown -R builder:builder /home/builder/aports

WORKDIR /home/builder
USER builder

ENTRYPOINT ["/bin/sh"]
