# 🏆 LineageOS 20.0 Final Post-Build Audit & Flashing Plan

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: July 31, 2026  
**Build Target**: `lineage-20.0-20260731-UNOFFICIAL-rog5s.zip`  
**Kernel Baseline**: Kirisakura Kernel (`kirisakura_defconfig`, ThinLTO, `55.59 MB`)

---

## 📊 1. Final Build Artifact Audit Matrix

| Artifact Filename | Size (Bytes) | Size (MB) | Full SHA-256 Digest | Status |
| :--- | :--- | :--- | :--- | :---: |
| **`lineage-20.0-20260731-UNOFFICIAL-rog5s.zip`** | `1,119,226,896` | `1067.38 MB` | **`a840ea0ab7f36278f9a4029bbfbc8fd151b9b471e959a4688d2f01a0c73c9b22`** | 🟢 **COMPLETE** |
| **`boot.img`** | `100,663,296` | `96.00 MB` | **`ca107797ab042dcc0d99066a5516d13c0962236b8ad2e602b5519f2208a9f096`** | 🟢 **VERIFIED** |
| **`stock_vendor_boot.img`** | `100,663,296` | `96.00 MB` | **`6adbbba02cd2b504aca26dfce26140a11b813299ca939d3ad9c0c5d2a9d174c9`** | 🟢 **VERIFIED** |
| **`lineage_vendor_boot.img`**| `100,663,296` | `96.00 MB` | **`f40f414ec0e1933d9d2edc41c23c142f5683b651752065dfc9cf1424c1c4d200`** | 🟢 **VERIFIED** |
| **`dtbo.img`** | `8,388,608` | `8.00 MB` | **`c82b9e6c46ee094a45a33c1d428fa6b8ad18d531ef5d4508ee062bf6aefef420`** | 🟢 **VERIFIED** |
| **`dtb.img`** | `1,429,937` | `1.36 MB` | **`a3d6c2196f1a797c517b04271b05582b4d1f2d95ae83dd289b4b188df6cf7779`** | 🟢 **VERIFIED** |

---

## 📦 2. `payload.bin` Partition Inspection

Inspection of `payload.bin` extracted directly from the OTA ZIP confirms the following payload contents:

| Partition Name | Included in OTA Payload? | Flashing Action by Recovery |
| :--- | :---: | :--- |
| **`boot`** | **YES** | Overwritten by `update_engine` |
| **`vendor_boot`** | **YES** | **Overwritten by `update_engine` (Requires Preservation Protocol)** |
| **`dtbo`** | **YES** | Overwritten by `update_engine` |
| **`vbmeta`** | **YES** | Overwritten by `update_engine` |
| **`vbmeta_system`** | **YES** | Overwritten by `update_engine` |
| **`system`** | **YES** | Written into `super` partition |
| **`vendor`** | **YES** | Written into `super` partition |
| **`product`** | **YES** | Written into `super` partition |
| **`system_ext`** | **YES** | Written into `super` partition |
| **`odm`** | **YES** | Written into `super` partition |

---

## ⚡ 3. Two-Stage Execution & Preservation Sequence

### Stage 1 — Lineage Userspace + Stock OEM `vendor_boot.img`

```powershell
# 1. Ensure slot A is active
fastboot set_active a

# 2. Flash Lineage Recovery Boot & Stock OEM vendor_boot
fastboot flash boot_a boot.img
fastboot flash vendor_boot_a stock_vendor_boot.img
fastboot flash dtbo_a dtbo.img

# 3. Boot into Lineage Recovery
fastboot reboot recovery

# 4. In Lineage Recovery:
#    a. Select "Factory Reset" -> "Format data/factory reset"
#    b. Select "Apply update" -> "Apply from ADB"

# 5. Sideload LineageOS OTA ZIP from PC:
adb sideload lineage-20.0-20260731-UNOFFICIAL-rog5s.zip

# 6. Preservative Reflash of Stock vendor_boot (Reboot to bootloader from recovery)
fastboot set_active a
fastboot flash vendor_boot_a stock_vendor_boot.img

# 7. First Boot into System
fastboot reboot
```

---

### Stage 2 — Complete Lineage Boot Chain (`lineage_vendor_boot.img`)

Without wiping data or reinstalling:

```powershell
# 1. Reboot to bootloader from working System
adb reboot bootloader

# 2. Swap ONLY vendor_boot_a to Lineage-built vendor_boot.img
fastboot set_active a
fastboot flash vendor_boot_a lineage_vendor_boot.img

# 3. Reboot into System
fastboot reboot
```

---

## 📋 4. Post-Boot Hardware Validation Checklist

Upon system boot, execute the following logging commands via ADB:

```bash
# 1. Core Environment Verification
adb devices
adb shell getenforce
adb shell uname -a
adb shell cat /proc/version
adb shell cat /proc/cmdline
adb shell "zcat /proc/config.gz | grep CONFIG_LOCALVERSION"

# 2. Log Collection
adb shell dmesg | grep -iE "panic|error|warn|bug|fail"
adb logcat -d *:E > logcat_errors.txt
```

### Hardware Verification Matrix:
- [ ] **ADB Connectivity**
- [ ] **Display & Touch Screen**
- [ ] **Wi-Fi (WLAN)**
- [ ] **Bluetooth**
- [ ] **Cellular / RIL (Calls, SMS, Mobile Data)**
- [ ] **Audio Playback (Speakers & Headphones)**
- [ ] **Front & Rear Cameras**
- [ ] **In-Display Fingerprint Sensor**
- [ ] **Sensors (Grip, Gyroscope, Accelerometer)**
- [ ] **Charging & Battery Statistics**
- [ ] **SELinux Enforcing Mode**
