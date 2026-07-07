# EnderWRT Long-Term Maintenance & Rebasing Strategy

This document outlines the standard operational procedures for maintaining EnderWRT, resolving upstream conflicts, and ensuring secure, repeatable builds over the lifetime of the project.

---

## 🔄 Upstream Rebasing Protocol

EnderWRT maintains strict modularity to allow clean rebases onto newer stable OpenWrt releases.

```
                  ┌──────────────────────┐
                  │   Upstream OpenWrt   │
                  │ (v23.05.3 -> v23.05.4)│
                  └──────────┬───────────┘
                             │
                             ▼
  ┌────────────┐     scripts/build.sh     ┌────────────┐
  │  EnderWRT  ├─────────────────────────>│  EnderWRT  │
  │ Patches &  │   * Auto-apply patches   │  Combined  │
  │ Customizer │   * Inject packages      │ Build Tree │
  └────────────┘   * Load seed configs    └────────────┘
```

### Upgrading the Base Version
To upgrade the base OpenWrt release target:
1.  Open [scripts/build.sh](file:///C:/Users/EnderBK/Downloads/agy_cli_windows_x64/scripts/build.sh).
2.  Update the `OPENWRT_VERSION` variable to the new tag (e.g., `v23.05.4` or `v24.10.0`):
    ```bash
    OPENWRT_VERSION="${OPENWRT_VERSION:-v23.05.4}"
    ```
3.  Execute the build script in dry-run/local mode to verify feeds resolution.

---

## 🛠️ Patch Management Strategy

Our build script applies patches from the [patches/](file:///C:/Users/EnderBK/Downloads/agy_cli_windows_x64/patches) directory. When upstream files change, patches may fail to apply.

### Resolving Patch Conflicts
If a patch fails during build setup:
1.  Navigate into the `openwrt-build` directory where the source code was checked out.
2.  Locate the failed patch (e.g., `patches/01-default-hostname-banner.patch`).
3.  Manually apply the patch and examine the rejects:
    ```bash
    git apply --reject ../patches/01-default-hostname-banner.patch
    ```
4.  Edit the `.rej` files to manually resolve the differences.
5.  Re-generate the patch file:
    ```bash
    git diff package/base-files > ../patches/01-default-hostname-banner.patch
    ```
6.  Commit the updated patch to the Git repository.

### Rules for Patches
-   **One concern per patch**: Do not combine branding changes and network configurations into a single patch file.
-   **Documentation**: Prefix each patch with comments explaining what it targets and why it is required.

---

## 🔒 Security Auditing & CVE Management

-   **Upstream Monitoring**: EnderWRT tracks stable OpenWrt security advisories. If a CVE is patched in upstream `v23.05`, the version in `scripts/build.sh` is bumped, triggering automatic recompilation of all target packages.
-   **Dependency Hygiene**: Minimize third-party package dependencies. Default to core OpenWrt packages where possible.
-   **Reproducibility Logs**: Keep the full compilation console output in GitHub Actions runs, including package checksums, to support security auditing.
