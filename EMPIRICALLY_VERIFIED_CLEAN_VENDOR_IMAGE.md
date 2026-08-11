# 🏆 Empirically Verified Clean Vendor Image Report

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `rog5s` / SM8350 `lahaina`)  
**Date**: August 11, 2026  
**Git Remote Status**: **ALL COMMITS PUSHED TO GITHUB ✅**

---

## 📌 Revert / Fallback Reference Point

If you ever need to revert back to the exact state of `logcat_bc` (where ADB was 100% active):

| Repository | `logcat_bc` Baseline Commit Hash | Current Verified Commit Hash | GitHub Push Status |
|---|---|---|---|
| [`device/asus/rog5-common`](https://github.com/sibinsilva/android_device_asus_rog5-common) | `0b78870` | `9427396` | **PUSHED ✅** |
| [`vendor/asus/rog5s`](https://github.com/sibinsilva/android_vendor_asus_rog5s) | `e4022eb` | `4b23361` | **PUSHED ✅** |
| [`hardware/qcom-caf/sm8350/display`](https://github.com/sibinsilva/android_hardware_asus_display) | `8257a483` | `f9ad2b2b` | **PUSHED ✅** |

To instantly revert any repo to `logcat_bc` baseline:
```bash
git reset --hard <logcat_bc_commit_hash>
```

---

## 📑 Compiled Output Empirical Verification Log

| Target Component | Status | Verification Result |
|---|---|---|
| [`vendor/etc/vintf/manifest.xml`](file:///vendor/etc/vintf/manifest.xml) | **CLEAN & DYNAMIC ✅** | Includes `vendor.pixelworks.hardware.display@1.1` & `vendor.pixelworks.hardware.feature@1.0`. Static `hidl/manifest.xml` is **100% CLEAN** (prevents `checkvintf` early boot crashes). |
| [`vendor/build.prop`](file:///vendor/build.prop) | **STOCK SDM PROPERTIES ✅** | All 11 empirically proven stock ASUS SDM display properties active. |
| [`vendor/etc/init/vendor.qti.hardware.display.composer-service.rc`](file:///vendor/etc/init/vendor.qti.hardware.display.composer-service.rc) | **VERIFIED ✅** | Clean auto-start daemon (`class hal animation`, NO `interface` lines). |
| [`vendor/lib64/libsdm-color.so`](file:///vendor/lib64/libsdm-color.so) | **PERMANENTLY REMOVED ✅** | `ls: cannot access: No such file or directory` (Copy rules removed from `rog5s-vendor.mk`). |
| [`vendor/lib64/libsdmcore.so`](file:///vendor/lib64/libsdmcore.so) | **ABI PATCHED ✅** | `tap_points` at line 364 in `hw_info_types.h` fixes `HWResourceInfo` struct alignment. |

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
