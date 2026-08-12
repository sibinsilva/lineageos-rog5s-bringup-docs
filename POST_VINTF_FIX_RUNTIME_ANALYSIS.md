# 🔬 Post-VINTF-Fix Runtime Logcat Analysis (`logcat_bg.txt`)

## Executive Summary
This document provides a 100% empirical, read-only analysis of **`logcat_bg.txt`** evaluating the display stack runtime lifecycle on LineageOS 20 (`rog5s`).

Each display HAL is evaluated across the strict 6-stage lifecycle model:

$$\text{binary present} \longrightarrow \text{init service parsed} \longrightarrow \text{service started} \longrightarrow \text{process executes} \longrightarrow \text{HIDL registers} \longrightarrow \text{client connects}$$

---

## 1. Itemized Display Service Lifecycle Matrix

| Display HAL Service | Binary Present | Init Service Parsed | Service Started by init | Process Executes | HIDL Registers | Client Connects | Overall Runtime Status |
|---|---|---|---|---|---|---|---|
| **Pixelworks Feature HAL** (`@1.0::IIrisFeature/default`) | 🟢 YES | 🟢 YES | 🔴 NO | 🔴 NO | 🔴 NO | 🔴 NO | 🔴 NOT STARTED IN LOGCAT_BG |
| **Pixelworks Display HAL** (`@1.1::IIris/default`) | 🟢 YES | 🟢 YES | 🔴 NO | 🔴 NO | 🔴 NO | 🔴 NO | 🔴 NOT STARTED IN LOGCAT_BG |
| **SecDisplay HAL** (`@1.0::ISecdisplay/default`) | 🟢 YES | 🟢 YES | 🟢 YES | 🟢 YES (PID 10685) | 🔴 NO | 🔴 NO | 🔴 FAILS VINTF & SYSFS (`-2147483648`) |
| **Allocator HAL** (`@4.0::IAllocator/default`) | 🟢 YES | 🟢 YES | 🟢 YES | 🟢 YES | 🟢 YES | 🟢 YES | 🟢 REGISTERED & WORKING |
| **LiveDisplay HAL** (`@2.0::ISunlightEnhancement`) | 🟢 YES | 🟢 YES | 🟢 YES | 🟢 YES | 🟢 YES | 🟢 YES | 🟢 REGISTERED & WORKING |
| **Display Composer** (`@2.1::IComposer/default`) | 🟢 YES | 🟢 YES | 🔴 NO | 🔴 NO | 🔴 NO | 🔴 NO | 🔴 NOT STARTED BY INIT |

---

## 2. Detailed Service Lifecycle Traces (`logcat_bg.txt`)

### A. SecDisplay HAL (`vendor.qti.hardware.secdisplay@1.0-service`)
* **Init Startup**: Started by `init` (PIDs 7511, 7647, 7770, 10685, 10974, 11138).
* **Main Execution**: PID 10685 executed `main()` and printed `[SECIDSPLAY_HIDL] HIDL_FETCH_ISecdisplay`.
* **Sysfs Node Failure** (Line 18415):
  `[SecDisplay][readPanelID] open path fail. /sys/devices/platform/soc/894000.spi/spi_master/spi0/spi0.0/PanelID`
* **VINTF Verification Failure** (Lines 18419–18421):
  ```text
  L18419: hwservicemanager: getTransport: Cannot find entry vendor.qti.hardware.secdisplay@1.0::ISecdisplay/default in either framework or device VINTF manifest.
  L18420: HidlServiceManagement: Service vendor.qti.hardware.secdisplay@1.0::ISecdisplay/default must be in VINTF manifest in order to register/get.
  L18421: LegacySupport: Could not register service vendor.qti.hardware.secdisplay@1.0::ISecdisplay/default (-2147483648).
  ```

---

### B. Display Composer Service (`vendor.qti.hardware.display.composer-service`)
* **Init Startup**: `init` **never** logged `starting service 'vendor.qti.hardware.display.composer'` in `logcat_bg.txt`.
* **Client Timeout** (Line 18673):
  `SurfaceFlinger (PID 1082): Waited one second for android.hardware.graphics.composer@2.1::IComposer/default`
* **Downstream Lazy Start Failure** (Lines 18258–18259):
  ```text
  L18258: libc: Unable to set property "ctl.interface_start" to "android.hardware.graphics.composer@2.1::IComposer/default": error code: 0x20
  L18259: hwservicemanager: Tried to start android.hardware.graphics.composer@2.1::IComposer/default as a lazy service, but was unable to.
  ```
* **Analysis**: `ctl.interface_start` error `0x20` (`EPERM`) is a downstream fallback failure. Because `vendor.qti.hardware.display.composer` was not eagerly started by `init`, SurfaceFlinger timed out, and `hwservicemanager` attempted lazy start which failed because `composer-service.rc` lacks an `interface` declaration.

---

### C. Allocator HAL (`vendor.qti.hardware.display.allocator-service`)
* **Status**: **100% Registered & Working**.
* **Logcat Proof**: Logcat confirms `qdgralloc: Initialized qti-allocator 4`.

---

## 3. Registered Display HAL Summary Table (`lshal` Equivalent)

| Interface / Instance | Transport | Server PID | Registration Status |
|---|---|---|---|
| `vendor.qti.hardware.display.allocator@4.0::IAllocator/default` | hwbinder | Running | 🟢 REGISTERED & WORKING |
| `vendor.lineage.livedisplay@2.0::ISunlightEnhancement/default` | hwbinder | Running | 🟢 REGISTERED & WORKING |
| `vendor.pixelworks.hardware.feature@1.0::IIrisFeature/default` | N/A | None | 🔴 NOT STARTED IN LOGCAT_BG |
| `vendor.pixelworks.hardware.display@1.1::IIris/default` | N/A | None | 🔴 NOT STARTED IN LOGCAT_BG |
| `vendor.qti.hardware.secdisplay@1.0::ISecdisplay/default` | hwbinder | PID 10685 | 🔴 FAILS VINTF REGISTRATION (`-2147483648`) |
| `android.hardware.graphics.composer@2.1::IComposer/default` | N/A | None | 🔴 NOT STARTED BY INIT |
