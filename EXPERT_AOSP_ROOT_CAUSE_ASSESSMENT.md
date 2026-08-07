# 🎓 Expert AOSP Root Cause Assessment: Display Stack Failures

> [!IMPORTANT]
> **Device:** ASUS ROG Phone 5s (`rog5s` / SM8350)  
> **Platform:** LineageOS 20.0 (Android 13 / VNDK v33)  
> **Evidence Source:** `logcat_vintf.txt` (18:38 UTC, Aug 7 2026) + Runtime linker investigation  
> **Status:** ANALYSIS COMPLETE — NO CODE CHANGES MADE

---

## 🔴 Issue 1: Hybrid Architecture Without Proper VNDK Bridging (Primary Root Cause)

### What we're doing wrong:
We are running a **proprietary stock OEM `composer-service`** binary on a **LineageOS-built system partition**. These two were never designed to be paired together. Stock ASUS compiled `composer-service` against their own system partition's VNDK layout — not LineageOS's.

### What AOSP mandates:
In Android 11+, `hardware/interfaces` HIDL libraries that a vendor binary needs must either:
- Be installed in `/vendor/lib64/` via a vendor variant (`android.hardware.graphics.composer@2.4.vendor` in `PRODUCT_PACKAGES`), **OR**
- Be exported from the system VNDK APEX to the vendor namespace via `linkerconfig`

The fact that `@2.1`, `@2.2`, `@2.3` resolve but `@2.4` does not tells us exactly one thing:  
**`@2.4` was not declared as a VNDK-Same or vendor-visible library in this build's VNDK snapshot.**

### The correct fix:
```makefile
# device.mk
PRODUCT_PACKAGES += android.hardware.graphics.composer@2.4.vendor
```
This is the AOSP-standard mechanism. Soong builds a vendor variant and installs it to `/vendor/lib64/` cleanly — **no Kati collision because it goes through Soong, not PRODUCT_COPY_FILES.**

> [!WARNING]
> **Why we previously reverted it:** We reverted `android.hardware.graphics.composer@2.4.vendor` because "ADB broke." However, we never confirmed whether ADB broke because of THIS change specifically or due to a concurrent build change. That root cause needs re-investigation before reverting again.

---

## 🔴 Issue 2: Post-Processing Injection Is Not a Valid AOSP Solution

### What we're doing:
Loop-mounting `vendor.img` and manually copying `composer@2.4.so` into `/vendor/lib64/`.

### Why this is architecturally wrong:
- Bypasses the build system entirely — no reproducible builds
- Injected library has no SELinux file context (confirmed: `rw-r--r-- 1 root root` without `+` ACL in image inspection)
- AVB/dm-verity rejects manually modified vendor partitions on verified-boot devices
- Any subsequent `m vendorimage` wipes the injection completely

---

## 🟡 Issue 3: 9+ Missing VINTF Manifest Entries

The log (`logcat_vintf.txt`) shows services failing to register because they are absent from the VINTF manifest:

| Missing HAL | Error |
|:---|:---|
| `android.hardware.drm@1.3::IDrmFactory/clearkey` | Must be in VINTF manifest |
| `android.hardware.drm@1.3::IDrmFactory/widevine` | Must be in VINTF manifest |
| `android.hardware.gnss@2.1::IGnss/default` | Must be in VINTF manifest |
| `android.hardware.neuralnetworks@1.3::IDevice/qti-default` | Must be in VINTF manifest |
| `vendor.asus.wifi.netutil@1.0` & `@1.1` | Must be in VINTF manifest |
| `vendor.asus.wifi.rttutil@1.0` | Must be in VINTF manifest |
| `vendor.ims.airtrigger@1.2` | Must be in VINTF manifest |
| `vendor.ims.asusgeneralhidl@1.0` | Must be in VINTF manifest |

**Why this matters:**  
`hwservicemanager` enforces VINTF compliance — any HAL not declared in the manifest cannot register. These require stock VINTF fragments to be carried from the OEM vendor tree.

---

## 🟡 Issue 4: 4 Additional Linker Failures Outside Display Stack

The following vendor binaries fail at dynamic linking — same root cause as `composer-service`:

```text
face@1.0-service.faceauth       → android.hardware.biometrics.face@1.0.so not found
vibratorcontrol2.service        → libqtivibratoreffect.so not found
ozoaudio.media.c2-service       → android.hardware.media.c2@1.1.so not found
vendor.qti.media.c2-service     → libgrallocutils.so not found
```

Each needs its own `.vendor` `PRODUCT_PACKAGES` entry or blob to be staged in the vendor tree.

---

## 🔴 Issue 5: DRM & IMS Service Fatal Crashes

```text
android.hardware.drm@1.3-service.clearkey  → SIGABRT: Failed to register Clearkey Factory HAL
android.hardware.drm@1.4-service.widevine  → SIGABRT: Failed to register Widevine Factory HAL
vendor.ims.airtrigger-service              → SIGSEGV: Null pointer dereference
vendor.ims.zenmotion-service               → SIGSEGV: Null pointer dereference
vendor.ims.wifi-service                    → SIGSEGV: Null pointer dereference
vendor.ims.glovemode-service               → SIGSEGV: Null pointer dereference
```

DRM crashes are caused by missing VINTF entries (Issue 3). IMS SIGSEGV crashes likely indicate a missing dependency or incompatibility in the IMS stack under LineageOS.

---

## ✅ Correct Expert Action Plan (Priority Order)

| Priority | Action | Mechanism | Status |
|:---|:---|:---|:---:|
| **1** | Add `android.hardware.graphics.composer@2.4.vendor` to `PRODUCT_PACKAGES` | Soong vendor variant (AOSP standard) | 🔴 Pending |
| **2** | Investigate **why ADB broke** when `@2.4.vendor` was previously added | Root cause isolation | 🔴 Pending |
| **3** | Add missing VINTF fragments from stock OEM to vendor tree | Carry stock `.xml` VINTF fragments | 🔴 Pending |
| **4** | Add remaining broken vendor library `.vendor` packages | Soong vendor variants for `face@1.0`, `media.c2@1.1`, etc. | 🔴 Pending |
| **5** | Remove post-processing injection — use build system properly | Replace with PRODUCT_PACKAGES approach | 🔴 Pending |

---

## 🎯 Evidence-Based Failure Chain

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

---

## 📋 Proven vs. Unproven

| Statement | Status |
|:---|:---:|
| `composer-service` aborts in linker before `main()` | ✅ **PROVEN by logcat** |
| Root cause: `@2.4.so` blocked by Bionic vendor namespace | ✅ **PROVEN by linker config audit** |
| Resolving `@2.4.so` allows `composer-service` to reach `main()` | ⚠️ **UNPROVEN — runtime experiment not completed** |
| Resolving `@2.4.so` is sufficient to boot the display stack | ⚠️ **UNPROVEN — further runtime failures may exist** |
| Post-processing injection is architecturally sound | ❌ **PROVEN INCORRECT** |

---

*Created: 2026-08-07T20:27:00Z*  
*Evidence: `logcat_vintf.txt` (18:38 UTC) + `RUNTIME_LINKER_ENVIRONMENT_INVESTIGATION.md`*
