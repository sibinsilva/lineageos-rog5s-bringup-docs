# 🚨 Spacewar Blob Cross-Contamination & Display Crash Cause Report

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `rog5s` / SM8350 `lahaina`)  
**Cross-Contaminated Blobs**: `spacewar` (Nothing Phone 1 / SM7325 `yupik`)  
**Build Fingerprint of Blob**: `Nothing/spacewar/spacewar:13/TKQ1.220915.002/1671077980:user/release-keys`  
**Date**: August 11, 2026

---

## 🎯 Major Discovery

In [`device/asus/rog5-common/proprietary-files.txt`](file:///mnt/android-build/device/asus/rog5-common/proprietary-files.txt#L713), the display vendor blobs were **borrowed from Nothing Phone (1) (`spacewar`)**:

```text
# Display - from spacewar - TKQ1.220915.002/1671077980
vendor/bin/hw/vendor.display.color@1.0-service
vendor/bin/ppd
vendor/bin/qdcmss
vendor/etc/display/DPU660.xml
vendor/etc/display/DPU670.xml
vendor/etc/display/DPU720.xml
vendor/etc/display/DPU7__.xml
vendor/etc/display/advanced_sf_offsets.xml
vendor/lib64/libsdm-color.so
vendor/lib64/libsdm-colormgr-algo.so
vendor/lib64/libsdm-diag.so
vendor/lib64/libsdm-disp-vndapis.so
vendor/lib64/libsdmextension.so
```

---

## 💥 Why This Caused the `std::__throw_length_error` Crash

1. **Chipset Incompatibility**:
   * **`spacewar` (Nothing Phone 1)** runs on **Snapdragon 778G+ (`SM7325` / `yupik`)** with DPU 670 display controller hardware.
   * **`rog5s` (ASUS ROG Phone 5S)** runs on **Snapdragon 888 (`SM8350` / `lahaina`)** with SDE DPU 720 display controller hardware.

2. **The ABI Breakdown**:
   * Open-source CAF display HAL in [`hardware/qcom-caf/sm8350/display`](file:///mnt/android-build/hardware/qcom-caf/sm8350/display) compiles [`libsdmcore.so`](file:///vendor/lib64/libsdmcore.so) specifically for **Snapdragon 888 (`SM8350`)**.
   * When [`libsdmcore.so`](file:///vendor/lib64/libsdmcore.so) calls `dlopen("libsdmextension.so")`, it loads the **Nothing Phone 1 (`SM7325`)** prebuilt library.
   * Because `libsdmextension.so` from SM7325 expects DPU 670 hardware structures and SM7325 `HWResourceInfo` definitions, passing SM8350 structures results in a total memory mismatch.
   * The copy constructor in `libsdmextension.so` attempts to parse SM7325 vectors out of SM8350 memory layout, causing **`std::__throw_length_error`** and crashing `vendor.qti.hardware.display.composer-service` with `SIGABRT`!

---

## 🛠 Resolution Options

1. **Option A: Pure CAF Display Stack (Remove `spacewar` Display Blobs)**
   * Remove the borrowed `# Display - from spacewar` blob lines (including `libsdmextension.so`) from `device/asus/rog5-common/proprietary-files.txt`.
   * Open-source CAF `libsdmcore.so` will run directly without attempting to load the foreign SM7325 `libsdmextension.so`.

2. **Option B: Use Stock ROG 5 / 5S (SM8350) Display Blobs**
   * Replace the `spacewar` (SM7325) blobs with the actual stock ROG 5 / ROG 5S (SM8350) OEM display blobs.
