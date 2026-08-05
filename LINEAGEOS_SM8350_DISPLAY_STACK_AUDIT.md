# 🔬 LineageOS SM8350 Display Stack Architecture & Git History Audit

---

## Executive Summary
This document presents an evidence-backed git history and source code audit of official LineageOS SM8350 device trees (`LineageOS/android_device_oneplus_sm8350-common`, `LineageOS/android_device_oneplus_lemonadep`, `LineageOS/android_device_asus_sake`). The goal is to establish the precise configuration of Qualcomm CAF display HALs, Pixelworks Iris co-processor integration, and Soong build variables required for Android 13 bring-up.

---

## 1. Display Stack Evolution & Architecture

### A. CAF Source vs. OEM Prebuilts
Official LineageOS SM8350 devices **do not use proprietary OEM display HAL binaries**. 
They compile the Qualcomm display HAL stack from source via `hardware/qcom-caf/sm8350/display`, while keeping the OEM Adreno GPU driver binaries (`libEGL_adreno.so`, `libgsl.so`, `libadreno_utils.so`) as proprietary blobs.

### B. Display Components Built from CAF Source
* **`vendor.qti.hardware.display.composer-service`**: HWC3 / HWC2 display composition HAL binary.
* **`vendor.qti.hardware.display.allocator-service`**: Gralloc 4.0 buffer allocator HAL binary.
* **`android.hardware.graphics.mapper@3.0-impl-qti-display`**: Gralloc 3.0 buffer mapper shared library.
* **`android.hardware.graphics.mapper@4.0-impl-qti-display`**: Gralloc 4.0 buffer mapper shared library.
* **`libsdmcore.so` & `libsdmutils.so`**: Snapdragon Display Manager hardware pipeline interface libraries.
* **`libgralloccore.so` & `libgrallocutils.so`**: Gralloc buffer management libraries.

---

## 2. Pixelworks Iris Co-Processor Integration

### Integration Architecture
* **Role**: Pixelworks Iris co-processor (`PXLW_IRIS_DUAL`, `Iris 6`) operates strictly as an **auxiliary sidecar service** (`LineageOS/android_hardware_pixelworks_interfaces` -> `vendor.pixelworks.hardware.display.iris-service`).
* **Display Pipeline**: Pixelworks does **not** replace the Qualcomm composer or gralloc stack. SurfaceFlinger and `libEGL_adreno.so` communicate directly with Qualcomm DPU (`msm_drm` / `/dev/dri/card0`) using standard QCOM CAF Gralloc 4.0 (`mapper@4.0-impl-qti-display`) and HWC3 (`composer-service`). The `iris-service` hooks in via I2C/SPI for MEMC frame interpolation and HDR color space adjustment.

---

## 3. `PRODUCT_PACKAGES` & Provenance (`LineageOS/android_device_oneplus_sm8350-common`)

Display packages included in `common.mk`:

```makefile
PRODUCT_PACKAGES += \
    android.hardware.graphics.mapper@3.0-impl-qti-display \
    android.hardware.graphics.mapper@4.0-impl-qti-display \
    init.qti.display_boot.rc \
    init.qti.display_boot.sh \
    vendor.qti.hardware.display.allocator-service \
    vendor.qti.hardware.display.composer-service \
    vendor.qti.hardware.display.composer-service.rc \
    vendor.qti.hardware.display.composer-service.xml
```

All display components are compiled from `hardware/qcom-caf/sm8350/display` source tree.

---

## 4. BoardConfig & Soong Configuration

In `BoardConfigCommon.mk`:

```makefile
# Display
SOONG_CONFIG_NAMESPACES += qtidisplay
SOONG_CONFIG_qtidisplay += default gralloc4 udfps
SOONG_CONFIG_qtidisplay_gralloc4 := true
TARGET_GRALLOC_HANDLE_HAS_RESERVED_SIZE := true
```

In `common.mk`:

```makefile
PRODUCT_SOONG_NAMESPACES += \
    hardware/qcom-caf/sm8350/display \
    hardware/pixelworks/interfaces
```

---

## 5. Blob Fixups (`extract-files.py`)

* **Adreno GPU Blobs**: `libEGL_adreno.so`, `libgsl.so`, and `libadreno_utils.so` are extracted directly without `blob_fixup()` binary modifications.
* **Fixups**: `extract-files.py` fixups apply to camera (`libcamx*`) and audio libraries to patch log tags or missing system symbols.

---

## 6. Comparison with Our Current ROG 5S Tree (`571ac44`)

| Display Layer | LineageOS Reference (`lemonadep` / `sake`) | Current ROG 5S Baseline (`571ac44`) | Source Status |
| :--- | :--- | :--- | :--- |
| **HWC3 Composer** | `vendor.qti.hardware.display.composer-service` (CAF Source) | ❌ **ABSENT** | Package missing from `PRODUCT_PACKAGES` |
| **Gralloc 4.0 Allocator** | `vendor.qti.hardware.display.allocator-service` (CAF Source) | ❌ **ABSENT** | Package missing from `PRODUCT_PACKAGES` |
| **Gralloc 4.0 Mapper** | `mapper@4.0-impl-qti-display` (CAF Source) | ❌ **ABSENT** | Package missing from `PRODUCT_PACKAGES` |
| **Gralloc Handle Size Flag** | `TARGET_GRALLOC_HANDLE_HAS_RESERVED_SIZE := true` | ❌ **ABSENT** | Missing in `BoardConfig.mk` |
| **Lineage BoardConfig Chain** | `include vendor/lineage/config/BoardConfigLineage.mk` | ❌ **ABSENT** | Missing in `BoardConfig.mk` |
| **Soong Namespaces** | `hardware/qcom-caf/sm8350/display` | ❌ **ABSENT** | Missing in `device.mk` |

---

## 7. Final Assessment: Top 10 Differences

| Rank | Difference | Evidence Classification | Supporting Source / Commit |
| :--- | :--- | :--- | :--- |
| **1** | **Absence of HWC3 `composer-service`** | Direct Evidence | `LineageOS/android_device_oneplus_sm8350-common@common.mk` |
| **2** | **Absence of Gralloc 4.0 `allocator-service`** | Strong Inference | `LineageOS/android_device_oneplus_sm8350-common@common.mk` |
| **3** | **Absence of `mapper@4.0-impl-qti-display`** | Strong Inference | `LineageOS/android_device_oneplus_sm8350-common@common.mk` |
| **4** | **Unset `TARGET_GRALLOC_HANDLE_HAS_RESERVED_SIZE := true`** | Direct Evidence | `LineageOS/android_device_oneplus_sm8350-common@BoardConfigCommon.mk` |
| **5** | **Missing `include vendor/lineage/config/BoardConfigLineage.mk`** | Direct Evidence | `LineageOS/android_device_asus_sake@BoardConfig.mk` |
| **6** | **Missing `SOONG_CONFIG_qtidisplay_gralloc4 := true`** | Direct Evidence | `vendor/lineage/config/BoardConfigQcom.mk` |
| **7** | **Absence of `init.qti.display_boot.sh`** | Direct Evidence | `LineageOS/android_device_oneplus_sm8350-common@common.mk` |
| **8** | **Missing VINTF Manifest Fragments for Display HALs** | Direct Evidence | `LineageOS/android_device_oneplus_sm8350-common@common.mk` |
| **9** | **Missing `hardware/qcom-caf/sm8350/display` in `PRODUCT_SOONG_NAMESPACES`** | Direct Evidence | `LineageOS/android_device_oneplus_sm8350-common@common.mk` |
| **10** | **Absence of Pixelworks Iris `vendor.pixelworks.hardware.display.iris-service`** | Strong Inference | `LineageOS/android_hardware_pixelworks_interfaces` |
