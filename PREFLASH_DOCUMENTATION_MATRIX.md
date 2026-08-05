# 📋 LineageOS 20.0 Pre-Flash Documentation Matrix

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: July 31, 2026  
**Kernel Baseline**: Kirisakura Kernel (`kirisakura_defconfig`, ThinLTO, `55.59 MB`)

---

## 📊 1. Pre-Flash Artifact Hashes & File Sizes

| Artifact Name | Exact File Size (Bytes) | Size (MB) | Full SHA-256 Digest | Status |
| :--- | :--- | :--- | :--- | :---: |
| **`boot.img`** | `100,663,296` | `96.00 MB` | **`ca107797ab042dcc0d99066a5516d13c0962236b8ad2e602b5519f2208a9f096`** | 🟢 Recorded |
| **`stock_vendor_boot.img`** | `100,663,296` | `96.00 MB` | **`6adbbba02cd2b504aca26dfce26140a11b813299ca939d3ad9c0c5d2a9d174c9`** | 🟢 Recorded |
| **`lineage_vendor_boot.img`**| `100,663,296` | `96.00 MB` | **`f40f414ec0e1933d9d2edc41c23c142f5683b651752065dfc9cf1424c1c4d200`** | 🟢 Recorded |
| **`dtb.img`** | `1,429,937` | `1.36 MB` | **`a3d6c2196f1a797c517b04271b05582b4d1f2d95ae83dd289b4b188df6cf7779`** | 🟢 Recorded |
| **OTA ZIP** | *(In progress)* | *(In progress)* | *Recorded upon `task-6599` completion* | ⏳ Pending |

---

## 🛡️ 2. `vendor_boot` Overwrite Policy & Preservation

1. **Payload Inspection**: Upon completion of `task-6599`, `payload.bin` inside the OTA ZIP will be inspected.
2. **Preservation Action**: If `payload.bin` updates `vendor_boot`, stock `vendor_boot.img` will be reflashed via fastboot immediately after sideloading and before first boot:
   ```powershell
   fastboot set_active a
   fastboot flash vendor_boot_a stock_vendor_boot.img
   ```

---

## ⚡ 3. Two-Stage Fastboot Flashing Commands

### Stage 1 — Lineage Userspace + Stock `vendor_boot.img`

```powershell
# 1. Ensure slot A is active
fastboot set_active a

# 2. Flash Lineage boot & Stock OEM vendor_boot
fastboot flash boot_a boot.img
fastboot flash vendor_boot_a stock_vendor_boot.img

# 3. Boot into Lineage Recovery
fastboot reboot recovery

# 4. In Recovery: Format data / Factory reset
# 5. In Recovery: Apply update -> Apply from ADB
adb sideload lineage-20.0-20260731-UNOFFICIAL-rog5s.zip

# 6. Preservation (reflash stock vendor_boot if overwritten by ZIP)
# fastboot flash vendor_boot_a stock_vendor_boot.img

# 7. First Boot into System
fastboot reboot
```

### Stage 2 — Complete Lineage Boot Chain (Rebuilt `vendor_boot.img`)

Without wiping data or reinstalling:

```powershell
# 1. Reboot to bootloader
adb reboot bootloader

# 2. Swap ONLY vendor_boot_a to Lineage-built vendor_boot.img
fastboot set_active a
fastboot flash vendor_boot_a lineage_vendor_boot.img

# 3. Reboot System
fastboot reboot
```

---

## 📋 4. Post-Boot Diagnostic Logging Protocol

Upon successful Stage 1 & Stage 2 boots, execute:

```bash
adb devices
adb shell getenforce
adb shell uname -a
adb shell cat /proc/version
adb shell cat /proc/cmdline
adb shell "zcat /proc/config.gz | grep CONFIG_LOCALVERSION"
adb shell dmesg | grep -iE "panic|error|warn|bug|fail"
adb logcat -d *:E > logcat_errors.txt
```
