# 🔬 Staged Investigation: Allocator Service Analysis & Experiment C Plan

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: August 3, 2026

---

## 📑 1. Analysis of `vendor.qti.hardware.display.allocator-service` Absence

| Question | Findings & Evidence |
| :--- | :--- |
| **Why was it absent from `/vendor/bin/hw/`?** | Soong generated the install rule (`out/soong/installs-lineage_rog5s.mk:180057`), but because the partial build command `m vendorimage` was executed after directory cleanup, Ninja packaged existing out binaries without building the `allocator-service` binary target. |
| **Was it excluded from `PRODUCT_PACKAGES`?** | **No.** It is explicitly listed on line 193 of `device/asus/rog5s/device.mk`. |
| **Was it replaced by another allocator?** | **No.** `vendor.qti.hardware.display.allocator-service` is the sole gralloc allocator HAL implementation for SM8350. |
| **Did Soong intentionally omit it?** | **No.** The module definition in `hardware/qcom-caf/sm8350/display/gralloc/Android.bp:158` is active and valid. |

---

## 🧪 2. Staged Experimentation Sequence

### 🎯 **Experiment C1: Restore Allocator Service Only**
- **Action**: Build or copy `vendor.qti.hardware.display.allocator-service` to `/vendor/bin/hw/` along with its minimal required dependencies.
- **Verification**: Perform 4-point audit on `allocator-service`.
- **Test Objective**: Flash and test whether SurfaceFlinger progresses beyond `eglInitialize()`.

### 🎯 **Experiment C2: Full Graphics Allocation ABI Set Alignment**
- **Trigger**: Executed **only if** Experiment C1 still aborts with `EGL_BAD_DISPLAY`.
- **Scope**: Package the full proprietary graphics allocation prebuilt set (`gralloc.default.so`, `libgrallocutils.so`, `mapper@4.0-impl-qti-display.so`).
