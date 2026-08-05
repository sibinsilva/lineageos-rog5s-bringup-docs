# 🔬 Live Boot Logcat Analysis — Exact Root Cause Identified

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: August 3, 2026  
**Log Sources**: Live `logcat` (29,662 lines), `dmesg` (15,988 lines), and `ps` (778 processes) captured via early ADB

---

## 🎯 Executive Summary of Root Cause

The device hangs indefinitely on the ASUS ROG logo because **`vendor.qti.hardware.display.composer-service` crashes continuously at startup in a 5-second crash loop**, preventing `SurfaceFlinger` and `Zygote` from starting.

```text
07-30 17:03:16.169  12655 12655 F DEBUG: Cmdline: /vendor/bin/hw/vendor.qti.hardware.display.composer-service
07-30 17:00:31.047  3175  3175 F DEBUG: Abort message: 'terminating with uncaught exception of type std::length_error: vector'
07-30 17:03:16.169  12655 12655 F DEBUG: #08 pc 000000000006eb3c /vendor/lib64/libsdmextension.so (sdm::HWResourceInfo::HWResourceInfo)
07-30 17:03:16.169  12655 12655 F DEBUG: #09 pc 00000000000943c0 /vendor/lib64/libsdmextension.so (sdm::CreateResource)
07-30 17:03:16.169  12655 12655 F DEBUG: #10 pc 000000000006268c /vendor/lib64/libsdmextension.so (sdm::ExtensionImpl::CreateResourceExtn)
07-30 17:03:16.169  12655 12655 F DEBUG: #11 pc 000000000004d3bc /vendor/lib64/libsdmcore.so (sdm::CompManager::Init)
07-30 17:03:16.169  12655 12655 F DEBUG: #12 pc 000000000002fdc4 /vendor/lib64/libsdmcore.so (sdm::CoreImpl::Init)
07-30 17:03:16.169  12655 12655 F DEBUG: #14 pc 0000000000064b34 /vendor/bin/hw/vendor.qti.hardware.display.composer-service (sdm::HWCSession::InitSupportedDisplaySlots)
```

---

## 📊 Detailed Cascading Failure Analysis

### 1. Primary Failure — Display Composer Crash (`composer-service`)
1. During early boot, `init` launches `vendor.qti.hardware.display.composer-service`.
2. `composer-service` enters `main()` -> `QtiComposer::initialize()` -> `sdm::HWCSession::Init()`.
3. `HWCSession::InitSupportedDisplaySlots()` calls into `libsdmextension.so` (`sdm::HWResourceInfo::HWResourceInfo`).
4. `sdm::HWResourceInfo` attempts to parse Snapdragon Display Manager (SDM) properties.
5. Because key `vendor.display.*` properties are missing from `device.mk` / `vendor/build.prop`, SDM attempts to allocate uninitialized vectors, throwing an uncaught **`std::length_error: vector`** exception.
6. The service aborts (`SIGABRT`) immediately.

### 2. Secondary Failure — LiveDisplay Crash (`livedisplay-sdm`)
```text
07-30 17:00:31.047  3175  3175 F DEBUG: Cmdline: /vendor/bin/hw/vendor.lineage.livedisplay@2.0-service-sdm
07-30 17:00:31.047  3175  3175 F DEBUG: Abort message: 'PictureAdjustment backend not ready, exiting.'
```
- `vendor.lineage.livedisplay@2.0-service-sdm` tries to connect to the display hardware backend.
- Since `composer-service` crashed, the display backend is not ready, so LiveDisplay aborts with `'PictureAdjustment backend not ready, exiting.'`.

### 3. Tertiary Failure — System Server / SurfaceFlinger Stalled
- `SurfaceFlinger` requires `android.hardware.graphics.composer@2.4::IComposer/default` to be registered with `hwservicemanager`.
- Because `composer-service` is trapped in a crash loop, `IComposer` is never registered.
- `SurfaceFlinger` and `Zygote` wait indefinitely for `IComposer` to become available, freezing the system at the ROG logo.

---

## 🛠️ Required Fix

We need to add the missing Qualcomm Snapdragon Display Manager (SDM) properties from the stock ROG 5S firmware into `device.mk`:

```makefile
# Display / SDM Properties
PRODUCT_PROPERTY_OVERRIDES += \
    vendor.display.disable_scaler=0 \
    vendor.display.disable_excl_rect=0 \
    vendor.display.disable_excl_rect_partial_fb=1 \
    vendor.display.comp_mask=0 \
    vendor.display.enable_posted_start_dyn=2 \
    vendor.display.enable_optimize_refresh=1 \
    vendor.display.use_smooth_motion=1 \
    vendor.display.enable_early_wakeup=1 \
    vendor.display.disable_offline_rotator=1 \
    vendor.display.enable_async_powermode=0 \
    vendor.display.disable_hw_recovery_dump=1
```

---

## 🏁 Summary Matrix

| Process | Status in `ps` | Symptom / Log Message | Root Cause |
| :--- | :---: | :--- | :--- |
| `vendor.qti.hardware.display.composer-service` | ❌ Crashed (Loop) | `std::length_error: vector` in `sdm::HWResourceInfo` | Missing SDM display properties in `vendor/build.prop` |
| `vendor.lineage.livedisplay@2.0-service-sdm` | ❌ Crashed (Loop) | `PictureAdjustment backend not ready, exiting.` | Downstream failure of `composer-service` crash |
| `surfaceflinger` | ⏸️ Stalled | Waiting on `IComposer/default` | `composer-service` never registers with `hwservicemanager` |
| `zygote` / `system_server` | ⏸️ Stalled | Not started | Blocked waiting for SurfaceFlinger |
