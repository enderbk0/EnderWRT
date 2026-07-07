# EnderWRT Product Roadmap & Feature Specification

This document details the development phases, technical specifications, and release schedule for future EnderWRT iterations.

---

## 🗺️ Phase Roadmap

### 📦 Phase 1: Core Architecture & CI/CD (Current)
*   **Target**: Stable build systems and visual styling.
*   **Key Deliverables**:
    *   Material Design 3 (Material You) custom LuCI theme.
    *   Automated GitHub Actions compilation pipelines.
    *   Build matrix for `x86_64` and `raspberrypi_4`.
    *   GPL compliance and OpenWrt base attribution.

### 🌐 Phase 2: Official Package Repository & Infrastructure (Q4 2026)
*   **Objective**: Establish a secure, high-speed OTA (Over-The-Air) update network.
*   **Key Features**:
    *   **Self-Hosted Package Repository**: Build an automated repository compiler (`ipkg-make-index`) that updates weekly.
    *   **HTTPS Feeds**: Transition from standard HTTP feeds to encrypted SSL feeds for package installation.
    *   **Package Signing**: Implement cryptographic package signing via `usign` keys, preventing middleman injection.
    *   **Mirror Network**: Set up a Cloudflare Pages/CDN distribution system to host built package assets.

### 🪄 Phase 3: Setup Wizard & User Onboarding (Q1 2027)
*   **Objective**: Bridge the gap between developer-centric OpenWrt configurations and average consumers.
*   **Key Features**:
    *   **luci-app-ender-setup**: A custom front-end application written in JS that launches automatically on first boot.
    *   **WAN Auto-Detection**: Auto-probes connection types (DHCP, PPPoE, Static IP) and guides the user.
    *   **Wireless Configuration**: Enforces a secure WPA3 password setup step before enabling radios.
    *   **Credentials Reset**: Replaces the default empty root password setup with a mandatory, complex administrator password.
    *   **Telemetry Toggle**: Optional, privacy-preserving opt-in dashboard telemetry (device model, uptime, region).

### 📶 Phase 4: Advanced Repeater & Captive Portal Engine (Q2 2027)
*   **Objective**: Power travelers, nomads, and public deployments.
*   **Key Features**:
    *   **Wireless WAN Auto-Scan (Repeater)**: A custom LuCI page (`luci-app-ender-repeater`) that background-scans for nearby networks and automatically establishes multi-uplink failover bridges.
    *   **Captive Portal Hijacker**: Integrates tools to assist with hotel/public Wi-Fi portal authorization by sharing MAC/IP mappings.
    *   **CoovaChilli / Nodogsplash Integration**: Built-in captive portal daemon for public hot-spot operators with local HTML templates.

### 🛠️ Phase 5: Custom LuCI App Ecosystem (Q3 2027)
*   **Objective**: Out-of-the-box system utilities.
*   **Key Features**:
    *   **luci-app-ender-adguard**: Native integration page for AdGuard Home, handling download, startup, DNS redirection, and logs.
    *   **luci-app-ender-wireguard**: Simplified interface to load `.conf` files from standard VPN providers.
    *   **Real-time Traffic Monitor**: An SVG-based traffic inspector showing client-by-client bandwidth consumption.

---

## 🛠️ Feature Technical Specification

### 1. Setup Wizard (`luci-app-ender-setup`)
The setup wizard will be built as an IPK package written in JavaScript (using modern LuCI Client-side views) and ucode.
```
luci-app-ender-setup/
├── root/
│   ├── etc/
│   │   ├── config/
│   │   │   └── ender-wizard                   # Tracks wizard state (enabled/disabled)
│   │   └── uci-defaults/
│   │       └── 99_ender_wizard_redirect       # Forces LuCI redirect if incomplete
│   └── usr/
│       └── share/
│           └── luci/
│               └── menu.d/
│                   └── luci-app-ender-setup.json
└── ucode/
    └── template/
        └── ender-wizard/
            └── wizard.ut                      # Fullscreen wizard view using TailwindCSS
```

### 2. Package Repository Compiler Script
We will implement an automated pipeline that checks out packages, runs `opkg-make-index.sh`, and signs the package index:
```bash
#!/bin/bash
# scripts/compile_repo.sh
# Invoked by Github Actions to build feed binaries
TARGET_ARCH=$1
mkdir -p bin/packages/$TARGET_ARCH
# Download packages ...
./scripts/ipkg-make-index.sh bin/packages/$TARGET_ARCH > bin/packages/$TARGET_ARCH/Packages
gzip -9c bin/packages/$TARGET_ARCH/Packages > bin/packages/$TARGET_ARCH/Packages.gz
# Sign with private key
usign -S -m bin/packages/$TARGET_ARCH/Packages -s key-build.priv
```
This guarantees absolute software integrity.
