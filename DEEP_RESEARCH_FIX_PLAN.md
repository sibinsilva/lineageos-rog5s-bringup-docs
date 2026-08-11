# 🔬 Deep Research Findings: Display Stack & Boot Failures

> [!IMPORTANT]
> **Device:** ASUS ROG Phone 5s (`rog5s` / SM8350)
> **Platform:** LineageOS 20.0 (Android 13 / VNDK v33)
> **Research Date:** 2026-08-07
> **Source:** 3 parallel expert AOSP research agents
> **Evidence:** `logcat_vintf.txt` (18:38 UTC), stock firmware dump, SM8350 reference device trees

---

## 🚨 CRITICAL FINDING: Do NOT Add `android.hardware.graphics.composer@2.4.vendor`

> [!CAUTION]
> **This was the cause of the previous ADB breakage.** This must never be added to `PRODUCT_PACKAGES`.

### Why `@2.4.vendor` breaks the device:
- **No SM8350 LineageOS device** (OnePlus 9, Xiaomi Mi 11, ASUS Zenfone 8 `sake`) uses `android.hardware.graphics.composer@2.4.vendor`
- SM8350 uses the **proprietary QTI composer** (`vendor.qti.hardware.display.composer-service`) which replaces the generic AOSP composer entirely
- Adding `@2.4.vendor` builds a **stub AOSP vendor library** that **conflicts** with the proprietary QTI display blobs
- Result: SurfaceFlinger crashes immediately → bootloop → ADB unreachable

### What SM8350 devices actually use:
```makefile
# Correct SM8350 display PRODUCT_PACKAGES pattern (oneplus9, mi11, sake)
vendor.qti.hardware.display.composer-service
vendor.qti.hardware.display.allocator-service
vendor.qti.hardware.display.mapper@1.1.vendor
vendor.qti.hardware.display.mapper@2.0.vendor
vendor.qti.hardware.display.mapper@3.0.vendor
vendor.qti.hardware.display.mapper@4.0.vendor
vendor.display.config@1.0.vendor
vendor.display.config@2.0.vendor
```

### Phase 1: Critical Display & Boot Stack Fixes (In Progress)

#### 1. Display Composer Kati Collision and Crashing
- **Root Cause:** A Kati build collision occurred between the AOSP generic `android.hardware.graphics.composer@2.4.so` and the proprietary Asus/QTI blob when added via `PRODUCT_COPY_FILES`.
- **Architectural Solution (Completed):**
  - Downloaded statically-linked `patchelf` (`0.17.2`).
  - Used `patchelf` on `vendor.qti.hardware.display.composer-service` and `vendor.qti.hardware.display.composer@3.0.so` to modify their `NEEDED` ELF dependencies from `android.hardware.graphics.composer@2.4.so` to `android.hardware.graphics.composer@2.4-qti.so`.
  - Renamed the proprietary blob to `android.hardware.graphics.composer@2.4-qti.so`.
  - Created a local `Android.bp` in `vendor/asus/rog5s/proprietary/vendor/lib64/` to expose `android.hardware.graphics.composer@2.4-qti` as a `cc_prebuilt_library_shared` module.
  - Added `android.hardware.graphics.composer@2.4-qti` to `PRODUCT_PACKAGES` in `device.mk`.
  - **Result:** This safely bypasses Kati install path collisions, leaving the AOSP library in place for generic dependents, while forcing the proprietary composer to load the vendor-specific blob. Build (`m vendorimage`) completed successfully.

---

## 🔴 Issue 1: `composer-service` Linker Failure (DISPLAY-CRITICAL)

**Error:** `CANNOT LINK EXECUTABLE: library "android.hardware.graphics.composer@2.4.so" not found`

**Root Cause:** `android.hardware.graphics.composer@2.4.so` is present in `/system/lib64/` but is NOT exported to the vendor namespace by Bionic's linker configuration. It must be in `/vendor/lib64/` directly.

**Correct Fix:**
```makefile
# vendor/asus/rog5s/rog5s-vendor.mk or display-vendor.mk
PRODUCT_COPY_FILES += \
    vendor/asus/rog5s/proprietary/vendor/lib64/android.hardware.graphics.composer@2.4.so:$(TARGET_COPY_OUT_VENDOR)/lib64/android.hardware.graphics.composer@2.4.so
```

**Source:** Extract from stock firmware dump at:
`/home/sibindev9746_gmail_com/rog5s_stock_firmware/dump/system/system/lib64/android.hardware.graphics.composer@2.4.so` (399 KB, MD5: `cc9bb94...`)

> [!NOTE]
> Ensure Soong does NOT also define an install target for this path. If a Kati collision occurs, remove any Soong-generated target for this library.

---

## 🟡 Issue 2: `face@1.0-service.faceauth` Linker Failure (NON-CRITICAL)

**Error:** `android.hardware.biometrics.face@1.0.so` not found

**Fix:** This is a standard AOSP HIDL interface (not a QTI-proprietary conflict), so the vendor variant IS safe here:
```makefile
# device.mk
PRODUCT_PACKAGES += android.hardware.biometrics.face@1.0.vendor
```

---

## 🟡 Issue 3: `vibratorcontrol2.service` Linker Failure (NON-CRITICAL)

**Error:** `libqtivibratoreffect.so` not found

**Fix:** This is a proprietary QTI blob — must be extracted from stock firmware:
- **Stock location:** `/home/sibindev9746_gmail_com/rog5s_stock_firmware/dump/vendor/lib/libqtivibratoreffect.so`
- **Stock location (64-bit):** `/home/sibindev9746_gmail_com/rog5s_stock_firmware/dump/vendor/lib64/libqtivibratoreffect.so`
- **Fix:** Add to `vendor/asus/rog5s/proprietary-files.txt`:
  ```
  vendor/lib/libqtivibratoreffect.so
  vendor/lib64/libqtivibratoreffect.so
  ```

---

## 🟡 Issue 4: `ozoaudio.media.c2-service` Linker Failure (NON-CRITICAL)

**Error:** `android.hardware.media.c2@1.1.so` not found

**Fix:** Standard AOSP HIDL — vendor variant IS safe:
```makefile
# device.mk
PRODUCT_PACKAGES += android.hardware.media.c2@1.1.vendor
```

---

## 🟡 Issue 5: `vendor.qti.media.c2-service` Linker Failure (NON-CRITICAL)

**Error:** `libgrallocutils.so` not found

**Fix:** Already staged from display HAL (`be618bf`). If still missing:
```makefile
PRODUCT_PACKAGES += libgrallocutils.vendor
```

---

## 🟡 Issue 6: Missing VINTF Manifest Entries (NON-CRITICAL for display boot)

**9+ HAL services fail to register** with `hwservicemanager` because their interfaces are absent from the device VINTF manifest.

**Fix:** Copy stock VINTF XML fragments from firmware dump:

| HAL | Stock Source File |
|:---|:---|
| `android.hardware.drm@1.3` (clearkey) | `dump/vendor/etc/vintf/manifest/manifest_android.hardware.drm@1.3-service.clearkey.xml` |
| `android.hardware.drm@1.3` (widevine) | `dump/vendor/etc/vintf/manifest/manifest_android.hardware.drm@1.3-service.widevine.xml` |
| `android.hardware.gnss@2.1` | `dump/vendor/etc/vintf/manifest/android.hardware.gnss@2.1-service-qti.xml` |
| `android.hardware.neuralnetworks@1.3` | `dump/vendor/etc/vintf/manifest/android.hardware.neuralnetworks@1.3-service-qti.xml` |
| `vendor.asus.wifi.*`, `vendor.ims.*` | `dump/vendor/etc/vintf/manifest/manifest_lahaina.xml` (extract relevant `<hal>` entries) |

**Stage destination:** `vendor/asus/rog5s/proprietary/vendor/etc/vintf/manifest/`

---

## 🟡 Issue 7: DRM SIGABRT Crashes (NON-CRITICAL for display boot)

**Crash:** `android.hardware.drm@1.3-service.clearkey` and `widevine` abort with:
`Failed to register [Clearkey/Widevine] Factory HAL`

**Root cause:** Same as Issue 6 — VINTF entries missing. Fixed by adding VINTF XML fragments (see Issue 6).

**Display impact:** NONE. SurfaceFlinger does not depend on DRM HALs.

---

## 🟡 Issue 8: IMS SIGSEGV Crashes (NON-CRITICAL — defer)

**Crash:** `vendor.ims.airtrigger`, `zenmotion`, `wifi`, `glovemode` all crash with `SIGSEGV fault addr 0x10`

**Root cause:** Null pointer dereference due to:
1. Missing VINTF entries → `hwservicemanager` returns `nullptr` on binder lookup
2. Missing ASUS-proprietary kernel nodes (`/dev/asus*`, `/sys/class/asus*`) not present under LineageOS kernel

**Recommendation:** Disable these services during bringup, or add `manifest_lahaina.xml` HAL entries to VINTF manifest.

**Display impact:** NONE.

---

## ✅ Prioritized Implementation Plan

| Priority | Fix | Files Changed | Boot Critical |
|:---|:---|:---|:---:|
| **1** | Stage `composer@2.4.so` as prebuilt blob | `proprietary-files.txt`, `display-vendor.mk` | 🔴 YES |
| **2** | `android.hardware.biometrics.face@1.0.vendor` | `device.mk` | 🟡 No |
| **3** | Stage `libqtivibratoreffect.so` blob | `proprietary-files.txt` | 🟡 No |
| **4** | `android.hardware.media.c2@1.1.vendor` | `device.mk` | 🟡 No |
| **5** | Copy DRM VINTF XML fragments from stock | `vendor/etc/vintf/manifest/` | 🟡 No |
| **6** | Copy GNSS + NNAPI VINTF XML fragments | `vendor/etc/vintf/manifest/` | 🟡 No |
| **7** | Copy `vendor.ims.*` VINTF entries from `manifest_lahaina.xml` | `device/asus/rog5s/hidl/manifest.xml` | 🟡 No |

---

## 📋 Evidence-Based Failure Chain (Confirmed)

```
composer@2.4.so blocked by Bionic vendor namespace
         ↓
composer-service aborts before main() [16:41:14.696]
         ↓
IComposer/default never registered with hwservicemanager
         ↓
SurfaceFlinger stalls indefinitely [16:41:15.897+]
         ↓
Display stack never initializes → Black screen
```

## ⚠️ Proven vs. Unproven

| Statement | Status |
|:---|:---:|
| `composer-service` aborts in linker before `main()` | ✅ PROVEN |
| Root cause: `@2.4.so` blocked by Bionic vendor namespace | ✅ PROVEN |
| `android.hardware.graphics.composer@2.4.vendor` causes bootloop | ✅ PROVEN (caused previous ADB breakage) |
| Staging `@2.4.so` as prebuilt blob resolves the display | ⚠️ UNPROVEN — needs runtime validation |
| Resolving `@2.4.so` is sufficient to fully boot display | ⚠️ UNPROVEN — further runtime failures may exist |

---

*Research completed: 2026-08-07T20:34:00Z*
*Agents: AOSP HIDL Vendor Variant Researcher (pro) + VINTF & Missing HAL Researcher (pro) + IMS & DRM Crash Researcher (flash)*
