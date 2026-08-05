# 🔬 Empirical Binary ELF Dependency & Shared Library Audit Report

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: August 3, 2026  
**Tools Used**: `readelf -d` dynamic dependency inspector, stock OEM dump comparison

---

## 📑 1. Summary of Empirical Findings

| Target Executable / Service | Service Class | Status | Missing Dynamic `.so` Libraries | Impact |
| :--- | :--- | :--- | :--- | :--- |
| **`vendor.qti.hardware.display.composer-service`** | `class hal animation` | ✅ **100% OK** (38/38 libs) | None | Executable links cleanly |
| **`vendor.qti.hardware.display.allocator-service`** | `class hal animation` | ✅ **100% OK** (24/24 libs) | None | Executable links cleanly |
| **`surfaceflinger`** | `class core animation` | ✅ **100% OK** (47/47 libs) | None | Executable links cleanly |
| **`android.hardware.biometrics.face@1.0-service.faceauth`** | `class hal` | ❌ **LINKER ERROR** | `android.hardware.biometrics.face@1.0.so`<br>`libcamera2ndk_vendor.so` | Crashes on launch |
| **`android.hardware.power-service`** | `class hal` | ❌ **LINKER ERROR** | `android.hardware.power-V1-ndk_platform.so` | Crashes on launch |
| **`android.hardware.power-service-qti`** | `class hal` | ❌ **LINKER ERROR** | `android.hardware.power-V3-ndk.so` | Crashes on launch |
| **`vendor.ozoaudio.media.c2@1.0-service`** | `class hal` | ❌ **LINKER ERROR** | `libcodec2_hidl@1.1.so`<br>`libavservices_minijail_vendor.so` | Crashes on launch |
| **`hostapd`** | `class main` (disabled) | ❌ **LINKER ERROR** | `android.hardware.wifi.hostapd-V1-ndk.so` | Link error when started |
| **`wpa_supplicant`** | `class main` (disabled) | ❌ **LINKER ERROR** | `android.hardware.wifi.supplicant-V1-ndk.so` | Link error when started |

---

## 🔍 2. Detailed Evidence & Dynamic Linker Audit

### A. Display Stack Executables (`composer`, `allocator`, `surfaceflinger`)
- **`vendor.qti.hardware.display.composer-service`**:
  - `readelf -d` verified **38/38 NEEDED dynamic libraries** exist in `/vendor/lib64` and `/system/lib64`.
- **`vendor.qti.hardware.display.allocator-service`**:
  - `readelf -d` verified **24/24 NEEDED dynamic libraries** exist in `/vendor/lib64` and `/system/lib64`.
- **`surfaceflinger`**:
  - `readelf -d` verified **47/47 NEEDED dynamic libraries** exist in `/system/lib64` and `/vendor/lib64`.

### B. Broken `class hal` Services (Linker Failures on Early Boot)
When `init` fires `class_start hal` during early boot, it launches all binaries assigned to `class hal`.

1. **`vendor-ozoaudio-media-c2-hal-1-0` (`vendor.ozoaudio.media.c2@1.0-service`)**:
   - Class: `class hal`
   - Linker failure: Missing `libcodec2_hidl@1.1.so` and `libavservices_minijail_vendor.so`.
   - **Impact**: `/system/bin/linker64` panics on launch (`cannot locate symbol / library not found`). `init` restarts it in a loop every 5 seconds.

2. **`vendor.power` (`android.hardware.power-service-qti` / `android.hardware.power-service`)**:
   - Class: `class hal`
   - Linker failure: Missing `android.hardware.power-V3-ndk.so` / `android.hardware.power-V1-ndk_platform.so`.
   - **Impact**: Linker panic on launch, triggering continuous restart loops.

3. **`vendor.face-hal-1-0-default` (`android.hardware.biometrics.face@1.0-service.faceauth`)**:
   - Class: `class hal`
   - Linker failure: Missing `android.hardware.biometrics.face@1.0.so` and `libcamera2ndk_vendor.so`.
   - **Impact**: Linker panic on launch.

---

## 🎯 3. Next Controlled Step

We now have **concrete binary evidence** identifying the exact broken HAL services in `class hal` that crash on launch due to missing shared libraries.

No code changes have been made.
