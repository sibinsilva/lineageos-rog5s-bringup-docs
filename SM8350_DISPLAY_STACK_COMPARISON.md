# 🔬 SM8350 Display Stack Architecture Comparison & Audit

## 1. Executive Summary
This document presents an evidence-based comparison of the display hardware abstraction layer (HAL) and graphics stack across official LineageOS 20 (Android 13) devices using the **Snapdragon 888 (`SM8350` / `lahaina`)** platform, specifically auditing **Pixelworks Iris hardware co-processor devices** vs. standard Qualcomm display implementations:

* **ASUS ROG Phone 5 / 5S** (`rog5` / `rog5s`) — Target Device (Pixelworks Iris 6 / `PXLW_IRIS_DUAL`)
* **OnePlus 9 Pro** (`lemonadep`) — Pixelworks X5 Pro Co-Processor
* **Xiaomi Mi 11** (`venus`) — Pixelworks Iris 5 Co-Processor
* **ASUS Zenfone 8** (`sake`) — Pure QCOM CAF Reference (No Pixelworks Chip)

---

## 2. Pixelworks Iris Co-Processor Architecture Audit

### Critical Architectural Finding
On all Pixelworks-equipped devices (OnePlus 9 Pro, Xiaomi Mi 11, ROG 5/5S):
1. **Primary Rendering & EGL**: SurfaceFlinger and the Adreno 660 GPU driver (`libEGL_adreno.so`) communicate **directly** with Qualcomm DRM (`/dev/dri/card0`) using the standard **QCOM CAF Display Stack** (`hardware/qcom-caf/sm8350/display`) via Gralloc 4.0 (`mapper@4.0-impl-qti-display`) and HWC3 (`vendor.qti.hardware.display.composer-service`).
2. **Pixelworks Role**: The Pixelworks Iris service (`vendor.pixelworks.hardware.display.iris-service` or `LineageOS/android_hardware_pixelworks_interfaces`) operates as an **auxiliary sidecar service**. It controls hardware post-processing (MEMC frame insertion, SDR-to-HDR conversion, color gamut mapping) over I2C/SPI commands directly to the Iris chip.
3. **EGL Independence**: Pixelworks Iris is **NOT** involved in EGL display initialization. `eglInitializeImpl()` relies strictly on QCOM Gralloc 4.0 (`mapper@4.0-impl-qti-display`) and DRM (`/dev/dri/card0`).

---

## 3. Comparison of Pixelworks-Equipped SM8350 LineageOS Devices

| Device | Platform (`SM8350`) | Display Panel | Co-Processor Hardware | Primary HWC & Gralloc HAL | Pixelworks Integration Method |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **OnePlus 9 Pro** (`lemonadep`) | SM8350 | Samsung LTPO E4 120Hz QHD+ | Pixelworks X5 Pro | **CAF Source** (`hardware/qcom-caf/sm8350/display`) | `LineageOS/android_hardware_pixelworks_interfaces` |
| **Xiaomi Mi 11** (`venus`) | SM8350 | Samsung E4 120Hz QHD+ | Pixelworks Iris 5 | **CAF Source** (`hardware/qcom-caf/sm8350/display`) | Xiaomi Display HIDL + `vendor.pixelworks` blobs |
| **ASUS ROG Phone 5** (`rog5`) | SM8350 | Samsung AMS678 144Hz FHD+ | Pixelworks Iris 6 (`PXLW_IRIS_DUAL`) | **CAF Source** (`hardware/qcom-caf/sm8350/display`) | OEM proprietary `vendor.pixelworks` blobs |
| **ASUS ROG Phone 5S** (`rog5s`) | **SM8350 (888+)** | **Samsung AMS678 144Hz FHD+** | **Pixelworks Iris 6** (`PXLW_IRIS_DUAL`) | **Current**: Baseline `571ac44` (OEM prebuilts cleaned, CAF unlinked) | OEM proprietary `.rc` file present |
| **ASUS Zenfone 8** (`sake`) | SM8350 | Samsung E4 120Hz FHD+ | **None** | **CAF Source** (`hardware/qcom-caf/sm8350/display`) | N/A (No Pixelworks hardware) |

---

## 4. CAF Source vs. Proprietary Vendor Blob Distribution Matrix

Across **all Pixelworks-equipped devices** (`lemonadep`, `venus`, `rog5`), the boundary between source-built components and proprietary blobs is **100% identical**:

### A. Display Components Built from CAF Source (`hardware/qcom-caf/sm8350/display`)
1. **`vendor.qti.hardware.display.composer-service`** (HWC3 Hardware Composer HAL binary)
2. **`vendor.qti.hardware.display.allocator-service`** (Gralloc 4.0 Memory Allocator HAL binary)
3. **`android.hardware.graphics.mapper@3.0-impl-qti-display`** (Gralloc 3.0 Mapper shared library)
4. **`android.hardware.graphics.mapper@4.0-impl-qti-display`** (Gralloc 4.0 Mapper shared library)
5. **`libsdmcore.so`** (Qualcomm SDM DPU Driver Core)
6. **`libsdmutils.so`** (SDM Display Utility Library)
7. **`libqdMetaData.so`** / **`libqdMetaData.system.so`** (Buffer Metadata Descriptor Library)
8. **`libgralloccore.so`** / **`libgrallocutils.so`** (Gralloc buffer handle utilities)

### B. Display Components Kept as Proprietary Vendor Blobs (`/vendor/lib64/`)
1. **Adreno 660 GPU Driver Blobs**: `libEGL_adreno.so`, `libGLESv1_CM_adreno.so`, `libGLESv2_adreno.so`, `libvulkan_adreno.so`
2. **Qualcomm GPU Compiler Blobs**: `libllvm-gsl.so`, `libgsl.so`, `libadreno_utils.so`
3. **Panel Calibration / Device Blobs**: Touchscreen firmware, panel DTBO (`msm_drm`), ASUS Splendid / LiveDisplay OEM daemon (`vendor.lineage.livedisplay@2.0-service.rog5s`).
4. **Pixelworks Iris Daemon**: `vendor.pixelworks.hardware.display@1.0-service` (Auxiliary picture mode tuning).

---

## 5. Evidence-Based Comparison Table: Pixelworks References vs. ROG 5S Baseline (`571ac44`)

| Component / Subsystem | OnePlus 9 Pro / Xiaomi Mi 11 / ROG 5 Reference | ROG 5S Current Baseline (`571ac44`) | CAF vs. Proprietary | Required for EGL Init? | Exact Difference | Confidence |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`vendor.qti.hardware.display.composer-service`** | Built from `hardware/qcom-caf/sm8350/display` | **ABSENT** in `/vendor/bin/hw/` | CAF Source | **REQUIRED** | HWC3 service binary missing from vendor partition | 🔴 **HIGH** |
| **`vendor.qti.hardware.display.allocator-service`** | Built from `hardware/qcom-caf/sm8350/display` | **ABSENT** in `/vendor/bin/hw/` | CAF Source | **REQUIRED** | Gralloc 4.0 Allocator service binary missing | 🔴 **HIGH** |
| **`android.hardware.graphics.mapper@4.0-impl-qti-display`** | Built from `hardware/qcom-caf/sm8350/display` | **ABSENT** in `/vendor/lib64/hw/` | CAF Source | **REQUIRED** | Gralloc 4.0 mapper shared library missing | 🔴 **HIGH** |
| **`libsdmcore.so`** | Built from `hardware/qcom-caf/sm8350/display` | **ABSENT** in `/vendor/lib64/` | CAF Source | **REQUIRED** | SDM DPU core driver library missing | 🔴 **HIGH** |
| **`libgrallocutils.so`** | Built from `hardware/qcom-caf/sm8350/display` | **ABSENT** in `/vendor/lib64/` | CAF Source | **REQUIRED** | Gralloc handle descriptor library missing | 🔴 **HIGH** |
| **`libEGL_adreno.so`** | Stock Vendor Blob (`/vendor/lib64/egl/`) | Stock Vendor Blob (`/vendor/lib64/egl/`) | Proprietary Blob | **REQUIRED** | **IDENTICAL** (Present in both) | 🟢 Matched |
| **`msm_drm` Kernel Driver** | Built-in kernel DRM driver (`/dev/dri/card0`) | Built-in kernel DRM driver (`/dev/dri/card0`) | Kernel Driver | **REQUIRED** | **IDENTICAL** (Present in kernel) | 🟢 Matched |
| **Pixelworks Interfaces** | `LineageOS/android_hardware_pixelworks_interfaces` | Proprietary Vendor Blobs | Open-Source / Blob | **OPTIONAL** | Auxiliary picture enhancement HAL | 🟢 Low Risk |
| **VINTF Manifest (`manifest.xml`)** | Declares `composer@3.0` & `allocator@4.0` | Declares `allocator@4.0`, missing `composer@3.0` | Device Config | **REQUIRED** | VINTF manifest incomplete for composer | 🟡 **MEDIUM** |
| **`PRODUCT_SOONG_NAMESPACES`** | Includes `hardware/qcom-caf/sm8350/display` | Includes `vendor/qcom/opensource/commonsys-intf/display` | Device Config | **REQUIRED** | SOONG namespace missing CAF display | 🟡 **MEDIUM** |

---

## 6. Top 10 Ranked Differences Most Likely to Cause `eglInitializeImpl(): EGL_BAD_DISPLAY`

1. **Rank 1: Absence of `vendor.qti.hardware.display.allocator-service` & `mapper@4.0`**: Adreno GPU driver (`libEGL_adreno.so`) relies on Gralloc 4.0 (`android.hardware.graphics.allocator@4.0` / `mapper@4.0`) to query buffer properties and register `/dev/dri/card0` file descriptors. When `eglInitializeImpl()` runs in SurfaceFlinger, `libEGL_adreno.so` queries Gralloc 4.0 for the default display framebuffer handle. If no Gralloc 4.0 allocator service is active or registered with Binder, `eglGetDisplay()` cannot acquire a valid native display window handle, returning `EGL_BAD_DISPLAY` (`0x3008`).
2. **Rank 2: Absence of `vendor.qti.hardware.display.composer-service` (HWC3)**: SurfaceFlinger initializes its main thread by binding to the HWComposer 3 service (`vendor.qti.hardware.display.composer-service`). If absent, SurfaceFlinger falls back to client composition, which forces `SkiaGLRenderEngine` to initialize an EGL display context without hardware display support.
3. **Rank 3: Missing `libgrallocutils.so` and `libsdmcore.so` Linkage**: Adreno EGL libraries depend on `libgrallocutils.so` to unparcel `native_handle_t` buffer handles created by the kernel DPU driver.
4. **Rank 4: VINTF Manifest Mismatch for Display HALs**: `framework_compatibility_matrix.xml` requires matching VINTF entries in `manifest.xml`.
5. **Rank 5: `PRODUCT_SOONG_NAMESPACES` Missing `hardware/qcom-caf/sm8350/display`**: Required for Soong to build CAF display binaries.
6. **Rank 6: Missing Display Configuration Libraries (`libdisplayconfig.qti` & `libdisplayconfig.system.qti`)**: Required for mode switching.
7. **Rank 7: Missing `vendor.display.config@2.0.vendor` Interface**: Display config HAL IPC interface.
8. **Rank 8: `gralloc.default.so` Fallback Collision**: Generic fallback gralloc collides with QCOM Gralloc 4.0.
9. **Rank 9: Pixelworks Iris Init Script Leftover (`vendor.pixelworks.hardware.display.iris-service.rc`)**: Uninitialized Iris daemon may block socket creation.
10. **Rank 10: `SOONG_CONFIG_qtidisplay_udfps` Flag**: Required for under-display fingerprint sensor layer ordering.

---

## 7. Conclusion
Pixelworks Iris devices (**OnePlus 9 Pro**, **Xiaomi Mi 11**, **ROG Phone 5**) use the **exact same QCOM CAF Display Stack** (`hardware/qcom-caf/sm8350/display`) for primary rendering as non-Pixelworks devices (`sake`). Pixelworks Iris acts purely as a sidecar post-processor and does not replace QCOM Gralloc 4.0 or HWC3.

Our frozen ADB debugging baseline (`571ac44`) is intact. The research comparison is complete!
