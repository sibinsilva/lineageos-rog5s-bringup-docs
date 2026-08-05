# 🔬 Build Graph Audit: Inheritance & CAF Display Subsystem Enablement

---

## Executive Summary
This document provides a static build-graph audit identifying why the ASUS Zenfone 8 (`sake`) tree builds the Qualcomm CAF display subsystem (`hardware/qcom-caf/sm8350/display`) from source, whereas the ROG 5S baseline (`571ac44`) omitted these targets. It outlines the exact makefile inclusion chains, Soong variables, and the minimal source-level change to align the ROG 5S display build graph 100% with `sake`.

---

## 1. Where `device/asus/sake` Pulls In Display Packages

### Direct Declarations in `device/asus/sake/device.mk` (Lines 166–194)
Unlike generic AOSP trees that rely on indirect macro inheritance, `device/asus/sake/device.mk` **directly declares the entire CAF display stack** in `PRODUCT_PACKAGES`:

```makefile
PRODUCT_PACKAGES += \
    android.hardware.graphics.common-V1-ndk_platform.vendor \
    android.hardware.graphics.mapper@3.0-impl-qti-display \
    android.hardware.graphics.mapper@4.0-impl-qti-display \
    android.hardware.lights-service.qti \
    android.hardware.memtrack@1.0-impl \
    android.hardware.memtrack@1.0-service \
    libdisplayconfig.qti \
    libdisplayconfig.system.qti \
    lights.qcom \
    libmemutils \
    libqdMetaData \
    libqdMetaData.system \
    libsdmcore \
    libsdmutils \
    libtinyxml \
    memtrack.default \
    vendor.display.config@1.0 \
    vendor.display.config@1.15.vendor \
    vendor.display.config@2.0 \
    vendor.display.config@2.0.vendor \
    vendor.lineage.livedisplay@2.0-service-sdm \
    vendor.lineage.livedisplay@2.0-service.sake \
    vendor.qti.hardware.display.allocator-service \
    vendor.qti.hardware.display.composer-service \
    vendor.qti.hardware.display.mapper@1.1.vendor \
    vendor.qti.hardware.display.mapper@2.0.vendor \
    vendor.qti.hardware.display.mapper@3.0.vendor \
    vendor.qti.hardware.display.mapper@4.0.vendor
```

---

## 2. Complete Make/Board Include Chain Comparison

```text
================================================================================
ASUS sake Include Chain                         ASUS rog5s Baseline (571ac44)
================================================================================
lineage_sake.mk                                 lineage_rog5s.mk
  │                                               │
  ├── inherit core_64_bit.mk                      ├── inherit core_64_bit.mk
  ├── inherit full_base_telephony.mk              ├── inherit full_base_telephony.mk
  ├── inherit device/asus/sake/device.mk          ├── inherit device/asus/rog5s/device.mk
  │     ├── PRODUCT_PACKAGES (INCLUDES CAF HALS)  │     ├── PRODUCT_PACKAGES (CAF HALs ABSENT ❌)
  │     └── PRODUCT_SOONG_NAMESPACES              │     └── PRODUCT_SOONG_NAMESPACES (display ABSENT ❌)
  └── inherit vendor/lineage/config/              └── inherit vendor/lineage/config/
        common_full_phone.mk                            common_full_phone.mk
                                                  
BoardConfig.mk                                  BoardConfig.mk
  │                                               │
  ├── BoardConfigMainlineCommon.mk                ├── BoardConfigMainlineCommon.mk
  ├── include BoardConfigLineage.mk (✅ PRESENT)  ├── include BoardConfigLineage.mk (ABSENT ❌)
  │     └── include BoardConfigQcom.mk            │
  │           ├── SOONG_CONFIG_qtidisplay         │
  │           └── SOONG_CONFIG_qtidisplay_gralloc4│
  └── TARGET_BOARD_PLATFORM := lahaina            └── TARGET_BOARD_PLATFORM := lahaina
```

---

## 3. First Point of Divergence

The build graph diverges at **two exact locations**:

1. **`device/asus/rog5s/device.mk` (Lines 166–194)**:
   The `rog5s` tree omitted the 5 core CAF display packages (`composer-service`, `allocator-service`, `mapper@3.0-impl`, `mapper@4.0-impl`, `libsdmcore`) from `PRODUCT_PACKAGES`.
2. **`device/asus/rog5s/BoardConfig.mk` (Line 14)**:
   The `rog5s` tree omitted `include vendor/lineage/config/BoardConfigLineage.mk`. This prevented `vendor/lineage/config/BoardConfigQcom.mk` from populating `SOONG_CONFIG_qtidisplay` and `SOONG_CONFIG_qtidisplay_gralloc4`.

---

## 4. Conditional Controls & Soong Variables

The inclusion and activation of each component is controlled by:

| Component | Controlling File | Soong Variable / Flag | Guard Mechanism |
| :--- | :--- | :--- | :--- |
| **`vendor.qti.hardware.display.composer-service`** | `device.mk` & `composer/Android.bp` | `PRODUCT_PACKAGES` & `qtidisplay_defaults` | `enabled: false` (Guard flag) |
| **`vendor.qti.hardware.display.allocator-service`** | `device.mk` & `gralloc/Android.bp` | `PRODUCT_PACKAGES` & `qtidisplay_defaults` | `enabled: false` (Guard flag) |
| **`android.hardware.graphics.mapper@4.0-impl-qti-display`** | `device.mk` & `gralloc/Android.bp` | `PRODUCT_PACKAGES` & `SOONG_CONFIG_qtidisplay_gralloc4` | `enabled: false` (Guard flag) |
| **`android.hardware.graphics.mapper@3.0-impl-qti-display`** | `device.mk` & `gralloc/Android.bp` | `PRODUCT_PACKAGES` & `qtidisplay_defaults` | `enabled: false` (Guard flag) |
| **`libsdmcore`** | `device.mk` & `sdm/libs/core/Android.bp` | `PRODUCT_PACKAGES` & `qtidisplay_defaults` | `enabled: false` (Guard flag) |

---

## 5. Minimal Source-Level Change to Match `sake` Inclusion Path

To align the `rog5s` build graph 100% with `device/asus/sake`:

### Step 1: `device/asus/rog5s/device.mk`
Add the missing CAF display packages to `PRODUCT_PACKAGES` and add the display Soong namespace:

```makefile
# Namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH) \
    hardware/qcom-caf/sm8350/display \
    kernel/asus/sm8350 \
    vendor/asus/rog5s

# Display
PRODUCT_PACKAGES += \
    android.hardware.graphics.common-V1-ndk_platform.vendor \
    android.hardware.graphics.mapper@3.0-impl-qti-display \
    android.hardware.graphics.mapper@4.0-impl-qti-display \
    android.hardware.lights-service.qti \
    android.hardware.memtrack@1.0-impl \
    android.hardware.memtrack@1.0-service \
    libdisplayconfig.qti \
    libdisplayconfig.system.qti \
    lights.qcom \
    libmemutils \
    libqdMetaData \
    libqdMetaData.system \
    libsdmcore \
    libsdmutils \
    libtinyxml \
    memtrack.default \
    vendor.display.config@1.0 \
    vendor.display.config@1.15.vendor \
    vendor.display.config@2.0 \
    vendor.display.config@2.0.vendor \
    vendor.lineage.livedisplay@2.0-service-sdm \
    vendor.lineage.livedisplay@2.0-service.rog5s \
    vendor.qti.hardware.display.allocator-service \
    vendor.qti.hardware.display.composer-service \
    vendor.qti.hardware.display.mapper@1.1.vendor \
    vendor.qti.hardware.display.mapper@2.0.vendor \
    vendor.qti.hardware.display.mapper@3.0.vendor \
    vendor.qti.hardware.display.mapper@4.0.vendor
```

### Step 2: `device/asus/rog5s/BoardConfig.mk`
Include the Lineage board configuration chain right below `BoardConfigMainlineCommon.mk`:

```makefile
include build/make/target/board/BoardConfigMainlineCommon.mk
include vendor/lineage/config/BoardConfigLineage.mk
```
