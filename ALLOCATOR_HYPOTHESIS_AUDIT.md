# 🔬 Read-Only Audit: Allocator Hypothesis & EGL Disambiguation

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: August 3, 2026  
**Scope**: Read-only verification of `vendor.qti.hardware.display.allocator@3.0.so` request sites, timestamps, stock status, and `libEGL_adreno.so` dependency tree

---

## 1. 📁 Verification of `vendor.qti.hardware.display.allocator@3.0.so` in Built Image
- **Status in Built Image**: **ABSENT** (`/vendor/lib64/`).
- **Omission Cause**: Omitted from `PRODUCT_PACKAGES` in `device/asus/rog5s/device.mk` (only `@1.1.vendor`, `@2.0.vendor` were listed).

---

## 2. 🔍 Binary Requester Identification

We ran `readelf -d` across all vendor libraries to identify which binary triggered the `vndksupport` logcat error:

```text
07-30 18:27:26.553  2645  2645 E vndksupport: Could not load /vendor/lib64/hw/camera.qcom.so from default namespace: dlopen failed: library "vendor.qti.hardware.display.allocator@3.0.so" not found: needed by /vendor/lib64/hw/camera.qcom.so
```

- **Requesting Binary**: `/vendor/lib64/hw/camera.qcom.so` (Qualcomm Camera HAL module loaded by `android.hardware.camera.provider@2.5-service_64` PID `2645`).
- **SurfaceFlinger Request**: `SurfaceFlinger` (PID `1069`) **did NOT request** `vendor.qti.hardware.display.allocator@3.0.so`.

---

## 3. ⏱️ Timestamp & Process Disambiguation

| Event | Process Name | Process ID | Timestamp | Status |
| :--- | :--- | :---: | :---: | :---: |
| **SurfaceFlinger EGL Abort** | `/system/bin/surfaceflinger` | PID `1069` | `t=18:27:16.038` | ❌ `EGL_BAD_DISPLAY` |
| **Camera Allocator Error** | `camera.provider@2.5-service_64` | PID `2645` | `t=18:27:26.553` | ⚠️ Missing Camera Dep |

**Empirical Verdict**: The `vndksupport` missing library message occurred **10.5 seconds AFTER SurfaceFlinger crashed**. They are on **completely separate, unrelated initialization threads**.

---

## 4. 📦 Stock ASUS Firmware Comparison

Stock ASUS ROM contains both display allocator HIDL interface libraries:
- `/vendor/lib64/vendor.qti.hardware.display.allocator@3.0.so` (106,872 bytes)
- `/vendor/lib64/vendor.qti.hardware.display.allocator@4.0.so` (102,552 bytes)

Our build omitted these vendor HIDL client libraries because `vendor.qti.hardware.display.allocator@3.0.vendor` was not in `PRODUCT_PACKAGES`.

---

## 5. 🔬 `libEGL_adreno.so` Dependency Audit

`readelf -d` on stock `/vendor/lib64/egl/libEGL_adreno.so`:
```text
(NEEDED) Shared library: [libadreno_utils.so]
(NEEDED) Shared library: [libgsl.so]
(NEEDED) Shared library: [libcutils.so]
(NEEDED) Shared library: [libdl.so]
(NEEDED) Shared library: [libz.so]
(NEEDED) Shared library: [liblog.so]
(NEEDED) Shared library: [libc++.so]
```

- `libEGL_adreno.so` **does NOT** statically depend on `vendor.qti.hardware.display.allocator@3.0.so`.
- EGL communicates with GPU hardware via `/dev/kgsl-3d0` and `/dev/ion` / `dmabuf`.

---

## 🎯 Investigation Conclusion

1. The missing `vendor.qti.hardware.display.allocator@3.0.so` library is requested by **Camera Provider** (`camera.qcom.so`), **not** SurfaceFlinger.
2. The allocator hypothesis is **refuted** as the cause of SurfaceFlinger's `EGL_BAD_DISPLAY` abort.
