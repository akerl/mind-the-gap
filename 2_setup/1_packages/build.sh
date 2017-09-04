#!/usr/bin/env bash

set -euo pipefail

# Some functions

function svc-enable() {
    systemctl enable "$1"
    systemctl start "$1"
}

function svc-disable() {
    systemctl disable "$1"
    systemctl stop "$1"
}

# Set up the core package management
haveged
pacman-key --init
KEYRING=/opt/share/config/1_prepare/0_os/archlinuxarm.keyring
KEYNAME=builder@archlinuxarm.org
PACMAN_GPG='gpg --no-permission-warning --homedir /etc/pacman.d/gnupg'
gpg --no-default-keyring --keyring "$KEYRING" --export | $PACMAN_GPG --import
pacman-key --lsign-key "${KEYNAME}"
pkill haveged
pacman -Syu --noconfirm archlinuxarm-keyring

# Set up the HW RNG
pacman -S --noconfirm rng-tools
svc-enable rngd

# Set up the clock
svc-disable systemd-timesyncd
# Once there's an RTC, time selection will go here

# Disable the network
svc-disable systemd-networkd
svc-disable systemd-resolved
svc-disable remote-fs.target
svc-disable sshd

# Set the MOTD
echo "Welcome." > /etc/motd

# Set the locale
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

# Remove unnecessary users
userdel alarm
rm -rf /home/alarm

# Remove unnecessary packages
pacman -R --noconfirm crda dhcpcd dialog haveged inetutils iputils iw jfsutils logrotate nano net-tools netctl openresolv openssh pciutils reiserfsprogs s-nail wireless-regdb wireless_tools wpa_supplicant xfsprofs ca-certificates ca-certificates-cacert ca-certificates-mozilla ldns libedit

# Install necessary packages
pacman -S --noconfirm vim-minimal
