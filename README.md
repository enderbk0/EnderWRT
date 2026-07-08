# 🛡️ EnderWRT

> A high-performance, size-optimized firmware distribution based on OpenWrt 23.05, tailored specifically for the 4MB Flash / 32MB RAM **TP-Link TL-WR940N v5/v6**.

[![Build Status](https://img.shields.io/github/actions/workflow/status/enderbk0/EnderWRT/build.yml?branch=main&style=flat-square&logo=github&label=Build)](https://github.com/enderbk0/EnderWRT/actions)
[![Platform](https://img.shields.io/badge/Platform-OpenWrt%2023.05-orange?style=flat-square)](https://openwrt.org/)
[![Target](https://img.shields.io/badge/Target-TL--WR940N%20v5%2Fv6-purple?style=flat-square)](#)
[![License](https://img.shields.io/badge/License-GPL--3.0-blue.svg?style=flat-square)](LICENSE)

EnderWRT is designed to pack modern interface styling and essential router services into extremely resource-constrained MIPS router hardware. It replaces OpenWrt's bulky defaults with custom-tailored configuration seeds and size-optimized profiles, ensuring stable performance on 4/32 devices.

---

## 🎨 Design System & Theme

EnderWRT is bundled with `luci-theme-ender`, a responsive LuCI web interface design inspired by **Material Design 3 (Material You)**.

*   **Responsive Framework**: Designed from the ground up for mobile, tablet, and desktop viewports.
*   **Automatic Dark Mode**: Built-in styling adapting to system `prefers-color-scheme` with manual toggle supports.
*   **Clean Geometry**: Modern card-based forms, pill-shaped menus, and custom Outfit typography.
*   **Ultralight Weight**: Static assets and SVG symbols are minified, taking up less than **30 KB** of physical flash.

---

## ⚡ Feature Matrix (IPv4 Only)

To fit within the **3.75 MB firmware partition limit**, the default build strips heavy networking protocols (like IPv6 and PPPoE/PPP) to preserve space for core functionalities:

*   **Wi-Fi Modes**: Wireless Access Point (AP), Client Mode, Client Bridge, Repeater, Repeater Bridge, and WDS.
*   **Core Services**: DHCP Server, DNS Forwarder (dnsmasq), and Firewall/NAT (nftables).
*   **Traffic Management**: Lightweight QoS traffic shaping.
*   **Built-in Captive Portal**: Ready-to-go splash landing overlays.

*Note: USB drivers, WireGuard, OpenVPN, Samba, and SQM are disabled by default but can be compiled in if flash expansion modifications (modding to 8MB/16MB chips) are made.*

---

## 📂 Repository Layout

EnderWRT maintains a **patchless, overlay-based architecture** to keep upstream rebasing seamless:

```
├── .github/workflows/
│   └── build.yml               # CI/CD Matrix Builder (Builds TL-WR940N)
├── branding/
│   ├── logo.svg                # Vector SVG logo
│   ├── boot_artwork.jpg        # Holographic gateway splash art
│   └── banner.txt              # ASCII terminal banner template
├── configs/
│   ├── x86_64.config           # Configuration seed for x86 targets
│   └── raspberrypi_4.config    # Configuration seed for RPi 4 targets
├── docs/
│   ├── roadmap.md              # Detailed future phase milestones
│   ├── maintenance.md          # Rebase protocols & conflict resolutions
│   └── customization_rationale.md # Details on overlay architecture (why we don't patch)
├── files/                      # Root filesystem custom file overlay
│   └── etc/
│       ├── banner              # Live SSH terminal banner
│       └── uci-defaults/
│           └── 99-enderwrt-defaults # First-boot hostname and theme configurator
├── profiles/
│   └── tplink/tl-wr940n/
│       ├── device.config       # Ultra-aggressive size-optimization configs
│       ├── default_packages.txt # Manifest of packages included/excluded
│       ├── build_profile.json  # Compilation targets metadata
│       ├── recovery.md         # TFTP recovery manual
│       └── image_generation.md # Flash partition offsets documentation
└── themes/
    └── luci-theme-ender/       # Custom Material Design 3 theme package
```

---

## 🛠️ Local Build Instructions

Requires a Linux compilation environment (Ubuntu 22.04 LTS recommended) with standard OpenWrt build-essential utilities installed.

### 1. Initialize Build Tree
Run the setup script specifying your device target:
```bash
./scripts/build.sh tplink_tl-wr940n-v6
```
This script pulls OpenWrt `v23.05.3` (stable/reproducible), installs standard package feeds, links the `luci-theme-ender` package, and injects the `/files` system overlay.

### 2. Compile Target
Navigate into the build tree and run compilation:
```bash
cd openwrt-build
make -j$(nproc) V=s
```
Output images (Factory, Sysupgrade, and TFTP recovery files) will be generated under `bin/targets/ath79/tiny/`.

---

## 🚑 TFTP Failsafe Recovery

If the router bootloops or gets corrupted, U-Boot can restore it via TFTP:

1.  Configure your PC's Ethernet network adapter to static IP **`192.168.0.66`** (Subnet `255.255.255.0`).
2.  Rename the compiled factory image to **`wr940nv6_tp_recovery.bin`** and place it in your local TFTP root folder.
3.  Connect your PC to one of the yellow **LAN ports** on the router.
4.  With the router powered off, press and **hold the Reset button**.
5.  Power on the router while keeping the Reset button held for 7-10 seconds until diagnostic LEDs flash rapidly. The router will download and flash the recovery file automatically.

---

## ⚖️ GPL & Upstream Compliance

*   **Attribution**: EnderWRT maintains clear links to upstream OpenWrt within all user-facing interfaces (LuCI login panels, footer details, and SSH banners).
*   **GPL Compliance**: In compliance with the GPL license, all customization scripts, configurations, and packages are fully open-sourced in this repository.
