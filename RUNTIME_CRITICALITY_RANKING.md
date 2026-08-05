# 🔬 Runtime Service Criticality Audit & Ranking Report

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: August 3, 2026  
**Scope**: 6 Vendor HAL Executables with Missing Shared `.so` Libraries

---

## 📑 1. Service-by-Service Runtime Analysis

### 1. `android.hardware.power-service-qti` & `android.hardware.power-service`
- **Service Name**: `vendor.power`
- **`.rc` Files**:
  - `/vendor/etc/init/android.hardware.power-service-qti.rc`
  - `/vendor/etc/init/android.hardware.power-service.rc`
- **Configuration Flags**:
  - `disabled`: **No** (Starts automatically during `class hal`)
  - `oneshot`: **No** (Restarted continuously every 5s by `init` on crash)
- **Earliest Boot Point**: `on boot` / `class_start hal` stage.
- **Linker Status**: Missing `android.hardware.power-V3-ndk.so` and `android.hardware.power-V1-ndk_platform.so`.
- **Special Finding**: **Dual Service Definition Collision**. Both `.rc` files declare `service vendor.power` under different binary paths. `init` attempts to launch both binaries, and both crash instantly on launch with dynamic linker errors.
- **Boot Criticality**: **HIGH / CRITICAL**. Both `SurfaceFlinger` and `SystemServer` query `IPower` AIDL interface (`android.hardware.power.IPower/default`) for rendering frame rate hints (`POWER_HINT_INTERACTION`).

---

### 2. `vendor.ozoaudio.media.c2@1.0-service`
- **Service Name**: `vendor-ozoaudio-media-c2-hal-1-0`
- **`.rc` File**: `/vendor/etc/init/vendor.ozoaudio.media.c2@1.0-service.rc`
- **Configuration Flags**:
  - `disabled`: **No** (Starts automatically during `class hal`)
  - `oneshot`: **No** (Restarted continuously every 5s by `init` on crash)
- **Earliest Boot Point**: `class_start hal` stage.
- **Linker Status**: Missing `libcodec2_hidl@1.1.so` and `libavservices_minijail_vendor.so`.
- **Boot Criticality**: **MEDIUM / LOW**. Auxiliary spatial audio codec HAL. Non-critical for display or core framework, but continuously restarts on loop.

---

### 3. `android.hardware.biometrics.face@1.0-service.faceauth`
- **Service Name**: `vendor.face-hal-1-0-default`
- **`.rc` File**: `/vendor/etc/init/android.hardware.biometrics.face@1.0-service.faceauth.rc`
- **Configuration Flags**:
  - `disabled`: **No** (Starts automatically during `class hal`)
  - `oneshot`: **No** (Restarted continuously every 5s by `init` on crash)
- **Earliest Boot Point**: `class_start hal` stage.
- **Linker Status**: Missing `android.hardware.biometrics.face@1.0.so` and `libcamera2ndk_vendor.so`.
- **Boot Criticality**: **LOW**. Non-essential face unlock biometric daemon.

---

### 4. `wpa_supplicant`
- **Service Name**: `wpa_supplicant`
- **`.rc` File**: `/vendor/etc/init/android.hardware.wifi.supplicant-service.rc`
- **Configuration Flags**:
  - `disabled`: **YES**
  - `oneshot`: **YES**
- **Earliest Boot Point**: Only when explicitly started by Android Framework Wi-Fi service late in boot.
- **Linker Status**: Missing `android.hardware.wifi.supplicant-V1-ndk.so`.
- **Boot Criticality**: **NONE (0)** during early boot. Does not run during early boot because it is marked `disabled`.

---

### 5. `hostapd`
- **Service Name**: `hostapd`
- **`.rc` File**: `/vendor/etc/init/hostapd.android.rc`
- **Configuration Flags**:
  - `disabled`: **YES**
  - `oneshot`: **YES**
- **Earliest Boot Point**: Only when explicitly started by SoftAP/Tethering service.
- **Linker Status**: Missing `android.hardware.wifi.hostapd-V1-ndk.so`.
- **Boot Criticality**: **NONE (0)** during early boot. Does not run during early boot because it is marked `disabled`.

---

## 🏆 2. Boot Criticality Ranking Table

| Rank | Service Name | Target Binary | Class | `disabled` | `oneshot` | Criticality Rating | Primary Reason |
| :---: | :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| 🥇 **1** | **`vendor.power`** | `android.hardware.power-service-qti`<br>`android.hardware.power-service` | `hal` | ❌ No | ❌ No | **CRITICAL** | **Power HAL**. Framework/SurfaceFlinger dependency. Has **dual .rc collisions** and missing `android.hardware.power-V3-ndk.so`. |
| 🥈 **2** | **`vendor-ozoaudio-media-c2-hal-1-0`** | `vendor.ozoaudio.media.c2@1.0-service` | `hal` | ❌ No | ❌ No | **MEDIUM** | Audio Codec2 HAL. Started in `class hal`. Re-executes on loop. |
| 🥉 **3** | **`vendor.face-hal-1-0-default`** | `android.hardware.biometrics.face@1.0-service.faceauth` | `hal` | ❌ No | ❌ No | **LOW** | Face Unlock HAL. Started in `class hal`. Re-executes on loop. |
| 4 | **`wpa_supplicant`** | `wpa_supplicant` | `main` | ✅ **Yes** | ✅ **Yes** | **NONE (0)** | Marked `disabled`. Never executed during early boot. |
| 5 | **`hostapd`** | `hostapd` | `main` | ✅ **Yes** | ✅ **Yes** | **NONE (0)** | Marked `disabled`. Never executed during early boot. |
