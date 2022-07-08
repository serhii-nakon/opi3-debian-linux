#!/usr/bin/env bash

set -e

LINUX_VERSION=5.18.9

apt update
apt full-upgrade -y
apt install build-essential linux-source bc kmod cpio flex bison libelf-dev libssl-dev libncurses5-dev rsync python3 dwarves wget gcc-aarch64-linux-gnu -y
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$LINUX_VERSION.tar.xz  -O - | tar xJ -C /root/build
cp -v /root/build/config /root/build/linux-$LINUX_VERSION/.config
cd /root/build/linux-$LINUX_VERSION
patch -p1 < /root/build/patches/0001-use_devm_regulator_get.patch
patch -p1 < /root/build/patches/0002-rename_phy_regulator_variable.patch
patch -p1 < /root/build/patches/0003-add_support_for_enabling_regulator.patch
patch -p1 < /root/build/patches/0004-enable_ethernet.patch
patch -p1 < /root/build/patches/0005-ath_regd_optional.patch
patch -p1 < /root/build/patches/0006-improve_mmc_and_wifi_speed.patch
scripts/config --enable ATH_USER_REGD
scripts/config --disable SECURITY_LOCKDOWN_LSM
scripts/config --disable MODULE_SIG
make -j$(nproc) bindeb-pkg LOCALVERSION=-my KDEB_PKGVERSION=$(make kernelversion)-1 ARCH=arm64 CROSS_COMPILE=/usr/bin/aarch64-linux-gnu-
cd /root/build/
rm -rf /root/build/linux-$LINUX_VERSION
echo Complete
