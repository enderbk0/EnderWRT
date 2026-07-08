# EnderWRT Customization Rationale & Architecture

EnderWRT is designed as a **thin, patchless customization layer** on top of upstream OpenWrt. This document details why our customizations exist, how they are implemented, and how we minimize the maintenance and rebasing burden.

---

## 🛠️ Customization Summary Table

| Customization | Reason for Existence | Upstream Modified? | Implementation Method | Rationale & Modularity |
|:---|:---|:---:|:---|:---|
| **luci-theme-ender** | Custom Material Design 3 theme (Dark mode, responsive) | **No** | Standalone Package (`package/enderwrt/`) | Packaged as a standard OpenWrt theme package. Does not modify any core LuCI source code. |
| **System Hostname** | Identifies the router as `EnderWRT` in GUI and CLI | **No** | Runtime overlay script (`99-enderwrt-defaults`) | Configured via `uci set` in a `uci-defaults` script. Requires no modifications to `config_generate`. |
| **Default Active Theme** | Forces LuCI to load the Ender theme on first boot | **No** | Runtime overlay script (`99-enderwrt-defaults`) | Set via UCI commands on first boot. Overrides default theme without modifying core LuCI defaults. |
| **SSH Terminal Banner** | Displays EnderWRT branding and license details | **No** | Custom Files Directory (`files/etc/banner`) | Injected using OpenWrt's native rootfs file overlay. Overwrites `/etc/banner` during image packaging without code diffs. |
| **TL-WR940N DTS & Profile** | Hardware mapping, LEDs, and flashing instructions | **No** | Inherited from Upstream Target (`ath79/tiny`) | Inherits the existing `tp9343_tplink_tl-wr940n-v6.dts` and image recipes directly. Requires no local copies. |

---

## 📐 Detailed Architectural Decisions

### 1. Inheriting Device Definitions (No Duplicate DTS)
*   **Decision**: We do not duplicate `tp9343_tplink_tl-wr940n-v6.dts` or buildroot profile makefiles in our repository.
*   **Why**: The TP-Link TL-WR940N (v5/v6) is already supported upstream under the OpenWrt `ath79/tiny` target.
*   **Benefit**: When the kernel is updated or pins are adjusted in newer OpenWrt versions, our builds automatically inherit these updates without requiring manual merges or resolving conflicts on DTS files.

### 2. Custom Files Overlay (`files/`)
*   **Decision**: We use the native OpenWrt `files/` folder layout to replace `/etc/banner`.
*   **Why**: Any files placed in `<buildroot>/files/` are automatically merged into the target root filesystem at build time, replacing default files.
*   **Benefit**: Eliminates the need to write and maintain patch files for `package/base-files`.

### 3. First-Boot Configurations (`uci-defaults`)
*   **Decision**: We apply custom system configuration settings (hostname, active theme) using a script in `/etc/uci-defaults/` rather than patching `config_generate`.
*   **Why**: A script placed in `/etc/uci-defaults/` is run automatically during the first boot. Once it exits with status `0`, OpenWrt deletes it.
*   **Benefit**: If OpenWrt modifies `config_generate` in future releases (which happens frequently to update timezone libraries or system mappings), our configuration setup remains unaffected and continues to function without modifications.

### 4. Standalone Packages
*   **Decision**: All custom packages and themes are added to a dedicated subfolder (`package/enderwrt/`) during the preparation phase.
*   **Why**: Separates the feed structure from standard packages.
*   **Benefit**: Keeps our development files completely segregated from the official OpenWrt feed codebase, permitting clean rebases.

### 5. 4MB Flash Size Optimization Strategy
*   **Decision**: We deselect heavy services like `opkg` (runtime package manager), PPPoE WAN drivers (`ppp`), and disable verbose kernel logs (`CONFIG_KERNEL_PRINTK`).
*   **Why**: Under 4MB flash layout constraint, the firmware partition cannot exceed 3.75MB. Standard LuCI with wireless drivers is too large for this footprint.
*   **Benefit**: Shrinks final SquashFS image size to fit safely inside the physical flash partition while retaining the responsive Material You web interface.

