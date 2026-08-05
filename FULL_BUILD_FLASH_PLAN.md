# 🚀 LineageOS 20.0 Pre-Flash Build Artifact Audit & Flashing Plan

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: July 31, 2026  
**Kernel Base**: Kirisakura Kernel (`kirisakura_defconfig`, ThinLTO, `55.59 MB`)

---

## 📊 1. Current Generated Build Artifacts Audit (`out/target/product/rog5s/`)

| Artifact Filename | Size (Bytes) | Size (MB) | SHA256 (First 16 chars) | Status |
| :--- | :--- | :--- | :--- | :---: |
| **`boot.img`** | `100,663,296` | `96.00 MB` | `ca107797ab042dcc...` | 🟢 **GENERATED** |
| **`vendor_boot.img`** | `100,663,296` | `96.00 MB` | `f40f414ec0e1933d...` | 🟢 **GENERATED** |
| **`dtb.img`** | `1,429,937` | `1.36 MB` | `a3d6c2196f1a797c...` | 🟢 **GENERATED** |
| **`ramdisk-recovery.img`**| `12,938,718` | `12.34 MB` | `41e2d85c19448327...` | 🟢 **GENERATED** |

---

## 🏗️ 2. Dynamic Partition & Userland Build Pipeline (`task-6599`)

Build task **`task-6599`** (`m bacon`) is compiling the complete LineageOS 20.0 system package:

- **Dynamic Partitions**: `system.img`, `vendor.img`, `product.img`, `system_ext.img`, `odm.img`
- **Super Container**: `super.img` (physical sparse container) or `super_empty.img`
- **AVB Metadata**: `vbmeta.img` & `vbmeta_system.img`
- **OTA Installable ZIP**: `lineage-20.0-*-UNOFFICIAL-rog5s.zip`

---

## ⚡ 3. Two-Stage Fastboot Flashing Protocol

### Stage 1: Isolate `boot.img` (Stock OEM `vendor_boot.img`)

Hold `vendor_boot` constant using Stock OEM `vendor_boot.img` to validate Lineage `boot.img` and system userland:

```powershell
# 1. Set active slot to 'a'
fastboot set_active a

# 2. Flash Lineage boot.img & Stock OEM vendor_boot
fastboot flash boot_a boot.img
fastboot flash vendor_boot_a stock_vendor_boot.img
fastboot flash dtb_a dtb.img

# 3. Flash Lineage Super Partition (contains system, vendor, product, system_ext, odm)
fastboot flash super super.img

# 4. Reboot into System
fastboot reboot
```

### Stage 2: Validate Complete Lineage Boot Chain (Rebuilt `vendor_boot.img`)

Swap only `vendor_boot_a` to test the Lineage-rebuilt vendor ramdisk:

```powershell
# 1. Set active slot to 'a'
fastboot set_active a

# 2. Flash Lineage-rebuilt vendor_boot
fastboot flash vendor_boot_a vendor_boot.img

# 3. Reboot into System
fastboot reboot
```

---

## 📋 4. Post-Boot Hardware Validation Checklist

Once Android boots to the home screen, execute the following hardware verification commands via ADB:

```bash
# 1. System & Kernel Version Verification
adb devices
adb shell getenforce
adb shell uname -a
adb shell cat /proc/version
adb shell cat /proc/cmdline
adb shell "zcat /proc/config.gz | grep CONFIG_LOCALVERSION"

# 2. Kernel & System Log Audit
adb shell dmesg | grep -iE "panic|error|warn|bug|fail"
adb logcat -d *:E > logcat_errors.txt
```

### Subsystem Verification Target List:
- [ ] ADB Connectivity
- [ ] Display & Touch Response
- [ ] Wi-Fi (WLAN)
- [ ] Bluetooth
- [ ] Cellular / RIL
- [ ] Audio Playback
- [ ] Front & Rear Cameras
- [ ] Fingerprint Sensor
- [ ] Environmental Sensors (Grip, Gyro, Accel)
- [ ] Charging & Battery Stats
- [ ] SELinux Enforcing Mode
