#!/usr/bin/env bash
#
# EnderWRT Firmware Build & Compilation Automator
# Copyright (C) 2026 EnderWRT Project
#

set -euo pipefail

# Configuration
OPENWRT_VERSION="${OPENWRT_VERSION:-v21.02.7}"
OPENWRT_REPO="https://github.com/openwrt/openwrt.git"
BUILD_DIR="openwrt-build"
TARGET_DEVICE="${1:-x86_64}" # Defaults to x86_64

echo "============================================="
echo "  EnderWRT Firmware Build Automator  "
echo "  Target: ${TARGET_DEVICE} (${OPENWRT_VERSION})"
echo "============================================="

# 1. Clone OpenWrt repository if it doesn't exist or is incomplete
if [ ! -f "$BUILD_DIR/scripts/feeds" ]; then
    echo "[-] OpenWrt source tree not found or incomplete. Setting up repository..."
    
    # Temporarily preserve cached directories
    ENDER_CACHE_TEMP="/tmp/ender_cache_preserve"
    mkdir -p "$ENDER_CACHE_TEMP"
    
    for dir in dl; do
        if [ -d "$BUILD_DIR/$dir" ]; then
            echo "[*] Preserving cached $dir..."
            mv "$BUILD_DIR/$dir" "$ENDER_CACHE_TEMP/"
        fi
    done
    
    # Remove the incomplete build directory
    rm -rf "$BUILD_DIR"
    
    # Clone OpenWrt source tree
    echo "[-] Cloning OpenWrt source tree..."
    git clone --depth 1 -b "$OPENWRT_VERSION" "$OPENWRT_REPO" "$BUILD_DIR"
    
    # Restore cached directories
    for dir in dl; do
        if [ -d "$ENDER_CACHE_TEMP/$dir" ]; then
            echo "[*] Restoring cached $dir..."
            mkdir -p "$BUILD_DIR"
            mv "$ENDER_CACHE_TEMP/$dir" "$BUILD_DIR/"
        fi
    done
    rm -rf "$ENDER_CACHE_TEMP"
else
    echo "[*] OpenWrt source tree already exists and is valid. Skipping clone."
fi

# Save the absolute root path of EnderWRT repository
ENDER_ROOT_DIR="$(pwd)"

cd "$BUILD_DIR"

# 2. Update and install feeds
echo "[-] Fetching and installing standard OpenWrt feeds..."
./scripts/feeds update -a
./scripts/feeds install -a

# 3. Inject EnderWRT custom packages and themes
echo "[-] Injecting EnderWRT customizations..."

# Copy theme
mkdir -p package/enderwrt/luci-theme-ender
cp -r "${ENDER_ROOT_DIR}/themes/luci-theme-ender/"* package/enderwrt/luci-theme-ender/

# Copy custom packages (if any exist)
if [ -d "${ENDER_ROOT_DIR}/packages" ] && [ "$(ls -A "${ENDER_ROOT_DIR}/packages")" ]; then
    echo "[-] Copying custom packages..."
    cp -r "${ENDER_ROOT_DIR}/packages/"* package/enderwrt/
fi

# 4. Copy Files Overlay (Static System Configurations)
echo "[-] Copying static files overlay..."
if [ -d "${ENDER_ROOT_DIR}/files" ]; then
    cp -r "${ENDER_ROOT_DIR}/files" .
fi

# 5. Load Build Configurations
if [ "$TARGET_DEVICE" = "tplink_tl-wr940n-v6" ]; then
    CONFIG_FILE="${ENDER_ROOT_DIR}/profiles/tplink/tl-wr940n/device.config"
else
    CONFIG_FILE="${ENDER_ROOT_DIR}/configs/${TARGET_DEVICE}.config"
fi

if [ -f "$CONFIG_FILE" ]; then
    echo "[-] Copying configurations for ${TARGET_DEVICE} from ${CONFIG_FILE}..."
    cp "$CONFIG_FILE" .config
    # Append theme configuration to ensure it's selected
    if [ "$TARGET_DEVICE" = "tplink_tl-wr940n-v6" ]; then
        cat <<EOF >> .config
CONFIG_PACKAGE_luci=n
CONFIG_PACKAGE_luci-light=n
CONFIG_PACKAGE_luci-base=y
CONFIG_PACKAGE_luci-mod-admin-full=y
CONFIG_PACKAGE_uhttpd=y
CONFIG_PACKAGE_uhttpd-mod-ubus=y
CONFIG_PACKAGE_luci-theme-ender=y
EOF
    else
        cat <<EOF >> .config
CONFIG_PACKAGE_luci-theme-ender=y
CONFIG_PACKAGE_luci-base=y
CONFIG_PACKAGE_uhttpd=y
EOF
    fi
else
    echo "[!] Warning: Configuration file $CONFIG_FILE not found! Generating default."
    cat <<EOF > .config
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_PACKAGE_luci-theme-ender=y
CONFIG_PACKAGE_luci=y
EOF
fi

# Expand configurations and verify
echo "[-] Running make defconfig to expand configurations..."
make defconfig

# 6. Download dependencies
echo "[-] Downloading build dependencies (this may take a while)..."
make download -j$(nproc)

echo "============================================="
echo "  EnderWRT ready for compilation!            "
echo "  To compile, run:                           "
echo "    cd ${BUILD_DIR}                          "
echo "    make -j\$(nproc) V=s                     "
echo "============================================="
