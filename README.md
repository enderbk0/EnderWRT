# 🛡️ EnderWRT - Custom OpenWrt-Based Router Firmware Distribution

EnderWRT is an open-source, highly polished custom router firmware distribution based on [OpenWrt](https://openwrt.org/) and licensed under the GNU General Public License (GPL).

EnderWRT combines OpenWrt's rock-solid stability and network performance with modern visual elegance (Material Design 3), simplified user onboarding, and a fully automated GitHub-first compilation pipeline.

---

## 🎨 Visual Aesthetics & Theme

EnderWRT comes packaged with `luci-theme-ender`, a bespoke theme for the OpenWrt LuCI web interface inspired by **Material Design 3 (Material You)**.

*   **Responsive Layout**: Optimized for desktop, tablet, and mobile screens.
*   **Dynamic Dark Mode**: Automatic theme shifting matching browser preferences (`prefers-color-scheme`) and supporting manual overrides.
*   **Material You Color Palettes**: Clean violet-to-teal gradients, pill-shaped buttons, and rounded cards.
*   **Inter/Outfit Typography**: Modern typography replace generic browser sans-serif fonts.

---

## 📂 Repository Layout

EnderWRT uses a modular layout to keep customizations distinct from core OpenWrt files, making upstream rebases straightforward:

```
├── .github/workflows/
│   └── build.yml               # CI/CD automated build matrix (x86_64, RPi 4, TL-WR940N)
├── branding/
│   ├── logo.svg                # Vector SVG logo for branding
│   ├── boot_artwork.jpg        # Holographic splash artwork
│   └── banner.txt              # Custom SSH terminal ASCII banner
├── configs/
│   ├── x86_64.config           # Target seed configuration for x86_64
│   └── raspberrypi_4.config    # Target seed configuration for Raspberry Pi 4
├── docs/
│   ├── roadmap.md              # Feature specification & development timeline
│   ├── maintenance.md          # Guide to rebasing, patching, & CVE audits
│   └── customization_rationale.md # Rationale behind code overlays & patchless architecture
├── files/                      # System configuration files overlay
│   └── etc/
│       ├── banner              # Custom SSH terminal banner
│       └── uci-defaults/
│           └── 99-enderwrt-defaults # First-boot hostname and theme configuration
├── packages/                   # Custom packages / feed overlays
├── patches/                    # Custom patches (empty by default to minimize maintenance)
├── profiles/                   # Build profiles for target device profiles
│   └── tplink/tl-wr940n/       # Optimized configurations and recovery manuals
├── scripts/
│   └── build.sh                # Automation script to prepare and expand OpenWrt buildroot
└── themes/
    └── luci-theme-ender/       # Custom LuCI theme package files (Makefile, static CSS/SVG, templates)
```

---

## 🛠️ Building EnderWRT Locally

To build EnderWRT locally, you will need a Linux machine (Ubuntu 22.04 LTS recommended) with standard OpenWrt build dependencies installed.

### 1. Prepare and Inject Environment
Run the setup script specifying your target device (`x86_64`, `raspberrypi_4`, or `tplink_tl-wr940n-v6`):
```bash
./scripts/build.sh tplink_tl-wr940n-v6
```
This script will:
*   Clone OpenWrt `v23.05.3` (stable, reproducible).
*   Download and update feeds.
*   Inject the `luci-theme-ender` package.
*   Apply branding patches.
*   Load the seed target configurations.
*   Run `make defconfig` to expand configurations.
*   Pre-download source tarballs.

### 2. Compile Firmware
Navigate into the compiled buildroot folder and run compilation:
```bash
cd openwrt-build
make -j$(nproc) V=s
```
Compiled images will be stored under `bin/targets/`.

---

## 🚀 CI/CD GitHub Actions Pipeline

EnderWRT features a fully automated build and release system:

*   **Nightly Builds**: Built automatically every night at `02:00 UTC`.
*   **Manual Trigger**: Kickoff custom builds via `workflow_dispatch` with options to create draft/pre-releases.
*   **Automatic Checksums**: Generates SHA256 hashes of all firmware builds.
*   **Auto Release Note Generator**: Publishes firmware binaries directly to GitHub Releases with changelogs.

---

## 🗺️ Roadmap & Futures
*   **Setup Wizard**: Easy step-by-step WAN/LAN/Wi-Fi configuration on first boot.
*   **OTA Package Feed**: Over-the-air cryptographically signed package repository.
*   **Advanced Repeater Config**: Simple UI to scan and auto-failover connection bridges.
*   Read more in [docs/roadmap.md](file:///C:/Users/EnderBK/Downloads/agy_cli_windows_x64/docs/roadmap.md).

---

## ⚖️ GPL Compliance & License

EnderWRT complies with the GNU General Public License (GPL).
*   All third-party OpenWrt code retains their original copyrights.
*   All modifications, patches, scripts, and theme sources are published openly under the same license terms.
*   Attribution to the upstream OpenWrt project must remain intact in all user-facing interfaces (e.g., LuCI login screen, footer credits, and SSH banner).
