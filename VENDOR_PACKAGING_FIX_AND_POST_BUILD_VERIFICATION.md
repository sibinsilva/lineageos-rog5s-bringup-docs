# 64-bit `libsdm-color.so` Vendor Packaging Fix & Post-Build Verification

## 1. Issue & Root Cause Summary

* **Symptom**: In post-VINTF fix boots (`logcat_bh.txt`), `vendor.qti.hardware.display.composer-service` (PID 947) was spawned eagerly by `init`, reached `main()`, initialized DRM hardware (discovering **1080x2448 @ 144Hz panel**), but aborted inside `HWCSession::Init()` at Line 6322:
  ```text
  DisplayBuiltIn::CreatePanelfeatures: Unable to load = libsdmextension.so, error = dlopen failed: library "libsdm-color.so" not found: needed by /vendor/lib64/libsdmextension.so
  DisplayBuiltIn::Init: Failed to setup panel feature factory, error: 2
  HWCSession::CreatePrimaryDisplay: Primary display creation has failed! status = -22
  ```
* **Root Cause**: [`vendor/asus/rog5s/rog5s-vendor.mk`](file:///mnt/android-build/vendor/asus/rog5s/rog5s-vendor.mk#L3253) had a copy rule for 32-bit `libsdm-color.so` in `/vendor/lib/`, but omitted the copy rule for 64-bit `libsdm-color.so` to `/vendor/lib64/`.

---

## 2. Applied Fix

* **Git Repository**: [`android_vendor_asus_rog5s`](https://github.com/sibinsilva/android_vendor_asus_rog5s)
* **Commit**: [`810f75a`](https://github.com/sibinsilva/android_vendor_asus_rog5s/commit/810f75a) (`rog5s: Add missing 64-bit libsdm-color.so vendor copy rule`)
* **Diff**:
  ```diff
  diff --git a/rog5s-vendor.mk b/rog5s-vendor.mk
  index c38c788..1a6d815 100644
  --- a/rog5s-vendor.mk
  +++ b/rog5s-vendor.mk
  @@ -3250,6 +3250,7 @@ PRODUCT_COPY_FILES += \
       vendor/asus/rog5s/proprietary/vendor/lib64/libscveObjectSegmentation_stub.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libscveObjectSegmentation_stub.so \
       vendor/asus/rog5s/proprietary/vendor/lib64/libscveObjectTracker.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libscveObjectTracker.so \
       vendor/asus/rog5s/proprietary/vendor/lib64/libscveObjectTracker_stub.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libscveObjectTracker_stub.so \
  +    vendor/asus/rog5s/proprietary/vendor/lib64/libsdm-color.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libsdm-color.so \
       vendor/asus/rog5s/proprietary/vendor/lib64/libsdm-colormgr-algo.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libsdm-colormgr-algo.so \
       vendor/asus/rog5s/proprietary/vendor/lib64/libsdm-diag.so:$(TARGET_COPY_OUT_VENDOR)/lib64/libsdm-diag.so \
  ```

---

## 3. Post-Build Verification

1. **`out/target/product/rog5s/vendor/lib64/libsdm-color.so`**:
   * File Exists: 🟢 **`True`**
   * Size: `423,264` bytes
   * Stock Blob MD5: `fe8b58792caa34fe55da14a027fd877c`
   * Target Image MD5: `fe8b58792caa34fe55da14a027fd877c`
   * Byte-for-Byte Match: 🟢 **`True`**

2. **`libsdmextension.so` Dynamic Linker Resolution (`llvm-readelf -d`)**:
   * `libsdm-color.so` ➔ `/vendor/lib64/libsdm-color.so` (🟢 **RESOLVED**)
   * **Total Missing Dependencies**: **`0` (ZERO MISSING DEPENDENCIES)**

---

## 4. Image Download Link

* **Verified `vendor.img`**: [`https://temp.sh/WMfzk/vendor.img`](https://temp.sh/WMfzk/vendor.img)
