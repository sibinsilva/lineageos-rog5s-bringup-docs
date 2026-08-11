# 🏆 Final Verified Display Vendor Image Report (V2)

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `rog5s` / SM8350 `lahaina`)  
**Date**: August 11, 2026  
**Status**: BUILD & ALL EMPIRICAL VERIFICATIONS COMPLETE ✅

---

## 📌 Artifact Download Link

* 📥 **`vendor.img` (1.1 GB)**: [`https://temp.sh/BplzP/vendor.img`](https://temp.sh/BplzP/vendor.img)

---

## 📑 Empirical Filesystem & VINTF Verification Log

| Target Component | Status | Empirical Verification Result |
|---|---|---|
| [`vendor/etc/vintf/manifest.xml`](file:///vendor/etc/vintf/manifest.xml) | **VERIFIED ✅** | Declares `graphics.composer@2.4`, `graphics.allocator@4.0`, `qti.composer@3.0`, `qti.allocator@4.0` |
| [`vendor/etc/init/vendor.qti.hardware.display.composer-service.rc`](file:///vendor/etc/init/vendor.qti.hardware.display.composer-service.rc) | **VERIFIED ✅** | Clean auto-start configuration (NO `interface` lines; auto-starts at boot second 6.9) |
| [`vendor/lib64/libsdm-color.so`](file:///vendor/lib64/libsdm-color.so) | **PERMANENTLY REMOVED ✅** | `ls: cannot access: No such file or directory` (Copy rules removed from `rog5s-vendor.mk`) |
| [`vendor/lib64/libsdmcore.so`](file:///vendor/lib64/libsdmcore.so) | **PRESENT (ABI PATCHED) ✅** | Compiled with `tap_points` at line 364 |
| [`vendor/bin/hw/vendor.qti.hardware.display.composer-service`](file:///vendor/bin/hw/vendor.qti.hardware.display.composer-service) | **PRESENT & LINKED ✅** | Compiled from CAF source |
| [`vendor/bin/hw/vendor.pixelworks.hardware.display.iris-service`](file:///vendor/bin/hw/vendor.pixelworks.hardware.display.iris-service) | **PRESENT ✅** | Pixelworks Iris coprocessor service |

---

## ⚡ Fastboot Flashing Instructions

```bash
# Reboot into bootloader mode
adb reboot bootloader

# Flash updated vendor partition
fastboot flash vendor vendor.img

# Reboot device
fastboot reboot
```
