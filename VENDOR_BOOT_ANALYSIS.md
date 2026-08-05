# 🔬 `vendor_boot.img` File-Level Analysis Report

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: July 31, 2026  
**Comparison Target**: Stock OEM `vendor_boot.img` vs. LineageOS 20.0 Rebuilt `vendor_boot.img`

---

## 📑 Executive Summary

Unpacking both `vendor_boot.img` files using `unpack_bootimg.py` and performing a recursive `find` audit on the extracted `vendor_ramdisk` archives revealed that Lineage's `vendor_boot.img` is a **meaningfully expanded rebuild** rather than a copy of stock:

- **Stock OEM Vendor Ramdisk**: Size is **`949 bytes`** (under 1 KB) and contains **only 1 file** (`first_stage_ramdisk/fstab.default`). ASUS stock firmware relies on the physical `/vendor` partition for all kernel modules and helpers.
- **Lineage Rebuilt Vendor Ramdisk**: Contains **`26 files`**, adding first-stage filesystem repair tools (`fsck.f2fs`, `e2fsck`, `resize2fs`, `tune2fs`) and essential 64-bit C libraries (`linker64`, `libc.so`, `libbase.so`, `libc++.so`).

---

## 📊 Comparison Matrix

| Parameter | Stock OEM `vendor_boot.img` | Lineage-Built `vendor_boot.img` | Status |
| :--- | :--- | :--- | :---: |
| **Image Size** | `100,663,296 bytes` (`96.0 MB`) | `100,663,296 bytes` (`96.0 MB`) | ✅ **IDENTICAL** |
| **Header Version** | Version 3 | Version 3 | ✅ **IDENTICAL** |
| **Vendor Ramdisk Size** | **`949 bytes`** | **`12.8 MB`** | ❌ **12.8 MB Diff** |
| **Total Ramdisk Files** | **`1 file`** | **`26 files`** | ❌ **+25 Files** |
| **DTB Blob** | OEM Device Tree (`1.36 MB`) | OEM Device Tree (`1.36 MB`) | ✅ **IDENTICAL** |

---

## 📂 Recursive `find` Listings

### 1. Stock OEM Vendor Ramdisk (`/tmp/stock_rd_all`)
```text
/tmp/stock_rd_all/first_stage_ramdisk/fstab.default
```

### 2. Lineage Rebuilt Vendor Ramdisk (`/tmp/lineage_rd_all`)
```text
/tmp/lineage_rd_all/first_stage_ramdisk/fstab.default
/tmp/lineage_rd_all/first_stage_ramdisk/fstab.emmc
/tmp/lineage_rd_all/system/bin/defrag.f2fs
/tmp/lineage_rd_all/system/bin/dump.f2fs
/tmp/lineage_rd_all/system/bin/e2fsck
/tmp/lineage_rd_all/system/bin/fsck.f2fs
/tmp/lineage_rd_all/system/bin/linker64
/tmp/lineage_rd_all/system/bin/resize.f2fs
/tmp/lineage_rd_all/system/bin/resize2fs
/tmp/lineage_rd_all/system/bin/tune2fs
/tmp/lineage_rd_all/system/lib64/ld-android.so
/tmp/lineage_rd_all/system/lib64/libbase.so
/tmp/lineage_rd_all/system/lib64/libc++.so
/tmp/lineage_rd_all/system/lib64/libc.so
/tmp/lineage_rd_all/system/lib64/libdl.so
/tmp/lineage_rd_all/system/lib64/libext2_blkid.so
/tmp/lineage_rd_all/system/lib64/libext2_com_err.so
/tmp/lineage_rd_all/system/lib64/libext2_e2p.so
/tmp/lineage_rd_all/system/lib64/libext2_quota.so
/tmp/lineage_rd_all/system/lib64/libext2_uuid.so
/tmp/lineage_rd_all/system/lib64/libext2fs.so
/tmp/lineage_rd_all/system/lib64/liblog.so
/tmp/lineage_rd_all/system/lib64/libm.so
/tmp/lineage_rd_all/system/lib64/libsparse.so
/tmp/lineage_rd_all/system/lib64/libz.so
```

---

## 🧪 Two-Stage Validation Sequence

### Stage 1: Isolate `boot.img` (Stock OEM `vendor_boot`)
Hold `vendor_boot` constant using Stock OEM `vendor_boot.img`:
```powershell
fastboot set_active a
fastboot flash boot_a boot.img
fastboot flash vendor_boot_a stock_vendor_boot.img
fastboot flash dtbo_a dtbo.img
fastboot flash super super.img
fastboot reboot
```

### Stage 2: Validate Lineage `vendor_boot.img`
Swap only `vendor_boot_a` to test the expanded Lineage vendor ramdisk:
```powershell
fastboot set_active a
fastboot flash vendor_boot_a lineage_vendor_boot.img
fastboot reboot
```
