# 🔬 Complete Build Inheritance Chain Audit: `sake` vs. `rog5s`

---

## Executive Summary
This document details the complete 10-stage build inheritance chain comparing the working ASUS SM8350 tree (`sake`) against the ROG 5S baseline (`571ac44`). It pinpoints the exact makefile line numbers, BoardConfig includes, Soong config namespaces, and HIDL generator rules that explain why official trees build `vendor.qti.hardware.display.composer-service` cleanly.

---

## Complete 10-Stage Build Graph Trace

```text
STAGE 1: AndroidProducts.mk
  │  sake:    PRODUCT_MAKEFILES := device/asus/sake/lineage_sake.mk
  │  rog5s:   PRODUCT_MAKEFILES := device/asus/rog5s/lineage_rog5s.mk
  └── Status: IDENTICAL STRUCTURE

STAGE 2: lineage_<device>.mk
  │  sake:    inherits core_64_bit.mk, full_base_telephony.mk, device.mk, common_full_phone.mk
  │  rog5s:   inherits core_64_bit.mk, full_base_telephony.mk, device.mk, common_full_phone.mk
  └── Status: IDENTICAL STRUCTURE

STAGE 3: device.mk (🔴 FIRST PRODUCT_PACKAGES DIVERGENCE)
  │  sake:    device/asus/sake/device.mk:166-194
  │           PRODUCT_PACKAGES += \
  │               android.hardware.graphics.mapper@3.0-impl-qti-display \
  │               android.hardware.graphics.mapper@4.0-impl-qti-display \
  │               libsdmcore \
  │               vendor.qti.hardware.display.allocator-service \
  │               vendor.qti.hardware.display.composer-service
  │  rog5s:   device/asus/rog5s/device.mk:170-190 (Baseline 571ac44)
  │           OMITTED all 5 CAF display packages from PRODUCT_PACKAGES ❌
  └── Status: DIVERGENT (Packages missing)

STAGE 4: BoardConfig.mk (🔴 FIRST BOARD_CONFIG DIVERGENCE)
  │  sake:    device/asus/sake/BoardConfig.mk (Lineage Standard)
  │           include vendor/lineage/config/BoardConfigLineage.mk (✅ PRESENT)
  │  rog5s:   device/asus/rog5s/BoardConfig.mk:14 (Baseline 571ac44)
  │           include vendor/lineage/config/BoardConfigLineage.mk (ABSENT ❌)
  └── Status: DIVERGENT (Lineage BoardConfig chain omitted)

STAGE 5: vendor/lineage/config Include Chain
  │  sake:    BoardConfigLineage.mk:7 ──► include vendor/lineage/config/BoardConfigQcom.mk
  │           BoardConfigQcom.mk:
  │             Line 65:  SOONG_CONFIG_NAMESPACES += qtidisplay
  │             Line 87:  SOONG_CONFIG_qtidisplay_default ?= true
  │             Line 122: SOONG_CONFIG_qtidisplay_gralloc4 := true
  │  rog5s:   Unexecuted because BoardConfigLineage.mk was missing from BoardConfig.mk ❌
  └── Status: DIVERGENT (Soong qtidisplay variables uninitialized)

STAGE 6: Soong Namespaces
  │  sake:    device/asus/sake/device.mk:293
  │           PRODUCT_SOONG_NAMESPACES += kernel/asus/sm8350 (qtidisplay inherited via lineage)
  │  rog5s:   device/asus/rog5s/device.mk:293 (Baseline 571ac44)
  │           PRODUCT_SOONG_NAMESPACES missing hardware/qcom-caf/sm8350/display ❌
  └── Status: DIVERGENT (Display Soong namespace omitted)

STAGE 7: hardware/qcom-caf/sm8350/display/Android.bp Guarding
  │  sake:    Modules enabled via qtidisplay_defaults soong_config_module_type
  │  rog5s:   Modules hardcode enabled: false in Android.bp:
  │             - composer/Android.bp:5
  │             - sdm/libs/core/Android.bp:2
  │             - gralloc/Android.bp:4, 40, 84, 122, 163
  └── Status: DIVERGENT (Requires explicit enabled: true on module stanzas)

STAGE 8: vendor/qcom/opensource/interfaces/display HIDL Header Generation
  │  sake:    vendor/qcom/opensource/interfaces/display/composer/3.0/Android.bp
  │           Parsed by hidl-gen to produce IQtiComposerClient.h & composer@3.0.so
  │  rog5s:   vendor/qcom/opensource/interfaces/display/composer/3.0/Android.bp.disabled
  │           File was named .disabled, causing missing IQtiComposerClient.h ❌
  └── Status: DIVERGENT (HIDL interface generator file disabled)

STAGE 9: Generated HIDL C++ Headers
  │  sake:    hidl-gen generates vendor/qti/hardware/display/composer/3.0/IQtiComposerClient.h
  │  rog5s:   Compilation failed with fatal error: 'IQtiComposerClient.h' file not found
  └── Status: DIVERGENT (Missing generated header)

STAGE 10: Final Target Output (`vendor.img`)
  │  sake:    /vendor/bin/hw/vendor.qti.hardware.display.composer-service built successfully
  │  rog5s:   Build failed at stage 3, 4, 7, and 8
  └── Status: DIVERGENT
```

---

## Summary of the 4 Primary Divergence Points

1. **`device/asus/rog5s/device.mk` (Lines 170–190)**:
   Omitted `vendor.qti.hardware.display.composer-service`, `vendor.qti.hardware.display.allocator-service`, `android.hardware.graphics.mapper@4.0-impl-qti-display`, and `libsdmcore` from `PRODUCT_PACKAGES`.
2. **`device/asus/rog5s/BoardConfig.mk` (Line 14)**:
   Omitted `include vendor/lineage/config/BoardConfigLineage.mk`. This prevented `vendor/lineage/config/BoardConfigQcom.mk` from setting `SOONG_CONFIG_NAMESPACES += qtidisplay`, `SOONG_CONFIG_qtidisplay_default := true`, and `SOONG_CONFIG_qtidisplay_gralloc4 := true`.
3. **`hardware/qcom-caf/sm8350/display/` `Android.bp` Files**:
   Modules (`composer-service`, `allocator-service`, `mapper@4.0-impl`, `libsdmcore`) contain hardcoded `enabled: false` on line 2-5 of their stanzas, requiring explicit `enabled: true` enablement.
4. **`vendor/qcom/opensource/interfaces/display/composer/3.0/`**:
   The `Android.bp.disabled` file was disabled with `.disabled` extension, preventing `hidl-gen` from synthesizing `vendor/qti/hardware/display/composer/3.0/IQtiComposerClient.h` headers.
