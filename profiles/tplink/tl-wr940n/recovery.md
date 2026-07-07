# TP-Link TL-WR940N (v5/v6) Firmware Recovery Guide

The TP-Link TL-WR940N router is equipped with a failsafe bootloader (U-Boot) that can pull and flash firmware automatically from a local network TFTP server if the main partition is bricked or corrupted.

---

## 📋 Prerequisites

Before starting the recovery process, ensure you have the following:

1.  **Ethernet Cable**: Connect your computer directly to one of the **yellow LAN ports** of the router. Do NOT use the blue WAN port.
2.  **TFTP Server Software**: Download and install a TFTP server.
    *   *Windows*: [Tftpd64](https://tftpd64.codeplex.com/) (recommended) or Tftpd32.
    *   *Linux*: `tftpd-hpa` or `dnsmasq` with TFTP enabled.
    *   *macOS*: Built-in tftp service or `tftp-server` via Homebrew.
3.  **Firmware Binary**: Use a valid recovery firmware. 

---

## ⚙️ Network Setup

You must configure your computer's Ethernet card with a static IP address, as the bootloader listens on a hardcoded IP block:

*   **IPv4 Address**: `192.168.0.66`
*   **Subnet Mask**: `255.255.255.0`
*   **Default Gateway**: *Leave Blank*

> [!WARNING]
> Disable all other network adapters (Wi-Fi, virtual adapters, VPNs) during this process, otherwise the TFTP server may bind to the wrong interface.

---

## 📁 Firmware File Naming

The bootloader will only request a specific file name matching its hardware version. 

Rename your compiled firmware binary or stock firmware to the matching name below and place it into the root directory of your TFTP server:

*   **For TL-WR940N v6**: **`wr940nv6_tp_recovery.bin`**
*   **For TL-WR940N v5**: **`wr940nv5_tp_recovery.bin`**

---

## ⚡ Triggering the Recovery

Follow these steps to initiate the flashing sequence:

1.  **Power Off**: Turn off the router using the power button or pull the power cable.
2.  **Reset Button**: Find the Reset pinhole button on the back of the router.
3.  **Hold and Boot**: 
    *   Using a paperclip or pin, press and **hold the Reset button**.
    *   While keeping the button held, **power on the router**.
4.  **Watch the LEDs**: Keep holding the Reset button for **7 to 10 seconds** until the WPS/SYS LEDs begin flashing rapidly or blink in unison.
5.  **Release Reset**: Release the Reset button.
6.  **Verify Transfer**: Watch the logs in your TFTP server software. You should see a connection request from `192.168.0.86` (the router) downloading the file (e.g., `wr940nv6_tp_recovery.bin`).

---

## 🏁 Post Flashing

*   Once the TFTP download finishes, the router will automatically write the image to flash and reboot. This takes about **2–3 minutes**. Do NOT interrupt power during this stage.
*   Once the system LED turns solid or flashes normally, restore your PC's network adapter settings to **Obtain an IP address automatically (DHCP)**.
*   Log in to EnderWRT at `http://192.168.1.1/`.
