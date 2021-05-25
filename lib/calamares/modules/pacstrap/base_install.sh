#!/bin/bash

PACSTRAP="/usr/bin/pacstrap_calamares"

make_pacstrap_calamares() {
    if [ -f "$PACSTRAP" ] ; then
        return
    fi
    sed -e '/chroot_add_mount proc/d'			\
        -e '/chroot_add_mount sys/d'			\
        -e '/ignore_error chroot_maybe_add_mount/d'	\
        -e '/chroot_add_mount udev/d'			\
        -e '/chroot_add_mount devpts/d'			\
        -e '/chroot_add_mount shm/d'			\
        -e '/chroot_add_mount \/run/d'			\
        -e '/chroot_add_mount tmp/d'			\
        -e '/efivarfs \"/d'				\
           /usr/bin/pacstrap > "$PACSTRAP"

    chmod +x "$PACSTRAP"
}

update_db() {
    # Update database step by step
    # For iso only
    # Necessary for old ISOs
    if [ -f "/tmp/upatedb_run_once" ] ; then
        return
    fi

    haveged -w 1024
    pacman-key --init
    pkill haveged
    pacman-key --populate
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

    if [ -x /usr/bin/update-mirrorlist ] ; then
        /usr/bin/update-mirrorlist
    else
        reflector --verbose	\
            --age 1		\
            --fastest 10	\
            --latest 70		\
            --protocol https	\
            --sort rate		\
            --save /etc/pacman.d/mirrorlist
    fi

    # No need to update db multiple times
    touch /tmp/upatedb_run_once
}

setup() {
    make_pacstrap_calamares
    update_db
}

run() {
    packages=(
        # base
        base
        linux
        linux-firmware
        mkinitcpio
        mkinitcpio-busybox
        efibootmgr
        grub
        device-mapper
        aperture-mirrorlist
        glados-keyring

        # important utils
        sudo
        base-devel
        xterm
        diffutils
        inetutils
        less
        man-db
        man-pages
        usbutils

        # file system utils
        cryptsetup
        e2fsprogs
        f2fs-tools
        btrfs-progs
        lvm2
        reiserfsprogs
        xfsprogs
        jfsutils
        mkinitcpio-nfs-utils
        sysfsutils
        mdadm

        # editors
        vim
        neovim
        nano

        # candy
        aperture-neofetch
        perl
    )

    chrootpath=$(cat /tmp/chrootpath.txt)
    "$PACSTRAP" "$chrootpath" "${packages[@]}"

    rsync -vaRI					\
        /usr/bin/chrooted_cleaner_script.sh	\
        /usr/bin/cleaner_script.sh		\
        /etc/pacman.conf			\
        /etc/pacman.d/mirrorlist		\
        /tmp/run_once				\
        /etc/default/grub			\
        "$chrootpath"
}

setup
run
