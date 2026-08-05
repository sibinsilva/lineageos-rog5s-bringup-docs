# 🔬 Experiment C1 Runtime Evaluation Report

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: August 3, 2026  
**Artifact File**: `logcat_expC1_crash.zip` / `logcat_expC1.txt` (8.3 MB)

---

## 📊 Summary of Results

### 1. `allocator-service` Status
- **Binary**: `/vendor/bin/hw/vendor.qti.hardware.display.allocator-service` (33,832 bytes) was successfully built and packaged into `vendor.img`.
- **HAL Registration**: `vendor.qti.hardware.display.allocator-service` executed during boot.

### 2. SurfaceFlinger & EGL Status
- **SurfaceFlinger Binder Connection**: `SurfaceFlinger: Using HWComposer service: default` (HAL connection active).
- **RenderEngine Failure**:
  ```text
  07-30 18:48:16.869  1911  1911 I SurfaceFlinger: SurfaceFlinger's main thread ready to run. Initializing graphics H/W...
  07-30 18:48:16.893  1911  1917 E libEGL  : eglInitializeImpl:281 error 3008 (EGL_BAD_DISPLAY)
  07-30 18:48:16.893  1911  1917 F RenderEngine: failed to initialize EGL
  ```

---

## 🎯 Outcome Classification

As defined in the test protocol:
- **Outcome 2 (Confirmed)**: `eglInitialize()` still returns `EGL_BAD_DISPLAY`.

**Empirical Conclusion**: Restoring `vendor.qti.hardware.display.allocator-service` alone is **insufficient** because the underlying gralloc allocator/mapper libraries (`gralloc.default.so`, `libgrallocutils.so`, `libgralloccore.so`, `mapper@4.0-impl-qti-display.so`) were built from open-source CAF code, creating an ABI mismatch with stock Adreno EGL drivers (`libEGL_adreno.so`).

---

## 🚀 Next Step: Experiment C2

Per protocol, we now proceed to **Experiment C2** by replacing the graphics allocation ABI prebuilt set as a single coherent unit:
1. `/vendor/bin/hw/vendor.qti.hardware.display.allocator-service` (`38,776 B`, stock prebuilt)
2. `/vendor/lib64/hw/gralloc.default.so` (`20,640 B`, stock prebuilt)
3. `/vendor/lib64/libgrallocutils.so` (`66,768 B`, stock prebuilt)
4. `/vendor/lib64/libgralloccore.so` (`101,280 B`, stock prebuilt)
5. `/vendor/lib64/hw/android.hardware.graphics.mapper@4.0-impl-qti-display.so` (`82,288 B`, stock prebuilt)
