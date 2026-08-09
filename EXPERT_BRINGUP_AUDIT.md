# 🔍 Expert LineageOS Bringup Audit (Revised) — ROG Phone 5 / 5s
**Based on actual file contents as of 2026-08-09**  
**Device:** `rog5s` (ZS676KS) / `rog5` (ZS673KS) | **Platform:** SM8350 (Lahaina)

> [!NOTE]
> Several issues in the earlier audit were incorrect — based on stale data from an earlier tree state. This document supersedes it with findings from the **real** current files.

---

## 🔴 CRITICAL — Must Fix Before Any Boot Attempt

### C1. `lineage_rog5.mk` is missing `core_64_bit.mk` and `full_base_telephony.mk`

`lineage_rog5s.mk` correctly inherits these:
```makefile
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
```

But `lineage_rog5.mk` only has:
```makefile
$(call inherit-product, device/asus/rog5/device.mk)
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)
```

**Impact:** Without `core_64_bit.mk`, the ROG 5 build will produce a 32-bit-only system image. Without `full_base_telephony.mk`, telephony stacks, IMS, and RIL packages will be missing. The device will fail to make calls or register on a cellular network.

**Fix:**
```makefile
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, device/asus/rog5/device.mk)
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)
```

---

### C2. `androidboot.selinux=permissive` hardcoded in `BoardConfigCommon.mk`

```makefile
BOARD_KERNEL_CMDLINE := \
    ...
    androidboot.selinux=permissive \
    buildvariant=userdebug
```

**Impact:**
- `androidboot.selinux=permissive` is acceptable during bringup **only**. But it is in `BoardConfigCommon.mk` — meaning it applies to **all** variant builds including `-user` releases. A shipped LineageOS ROM with SELinux permanently disabled will fail Play Integrity, have no app sandboxing, and will be rejected by LineageOS Gerrit.
- `buildvariant=userdebug` in the kernel cmdline is non-standard and meaningless to the kernel. It clutter the cmdline and can confuse device properties parsing.

**Fix:** Remove both. SELinux will be enforcing by default. If you need permissive during bringup, pass it temporarily via `fastboot --cmdline` or set it in `init.rog5s.rc` with `setenforce 0` guarded by a build variant check.

---

### C3. `device/asus/rog5` has no `.git` repository

```
device/asus/rog5/
├── AndroidProducts.mk
├── BoardConfig.mk
├── device.mk
├── lineage_rog5.mk
└── prebuilts/
```
*No `.git` directory.*

**Impact:** `repo sync` does not know this tree exists. It cannot be submitted to LineageOS Gerrit. Build system integration via `repo` manifests is broken for `rog5`. Any developer cloning your manifests will not get `device/asus/rog5`.

**Fix:** Initialize git, add the remote (`android_device_asus_rog5`), push, and add a `roomservice.xml` / `local_manifests` entry.

---

### C4. `PRODUCT_PROPERTY_OVERRIDES` forces ADB open on ALL builds including `-user`

In `rog5-common/device.mk`:
```makefile
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.usb.config=adb \
    ro.adb.secure=0
```

**Impact:** This is in the **common device.mk** — inherited by both `rog5` and `rog5s` in all variants. `ro.adb.secure=0` means ADB never requires authorization on **any** build including `-user`. This:
- Disables Android's USB authorization security model.
- Will be immediately rejected by LineageOS Gerrit.
- Makes the device insecure for any end user who installs it.

**Fix:** Wrap in a build variant conditional or move exclusively to a debug-only prop file:
```makefile
ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.usb.config=adb \
    ro.adb.secure=0
endif
```

---

### C5. ~~`PRODUCT_ENFORCE_VINTF_MANIFEST := false`~~ — ✅ Intentionally disabled for initial bringup

**Context confirmed by developer:** VINTF manifest enforcement is deliberately disabled during the initial bringup phase while HAL declarations are being stabilized. This is an accepted bringup practice.

> [!WARNING]
> **Must be re-enabled before any public/official build.** Track this as a known TODO. When you're ready, remove `PRODUCT_ENFORCE_VINTF_MANIFEST := false` from both `rog5-common/device.mk` and `lineage_rog5s.mk`, and fix all resulting VINTF errors one by one.

The `VINTF_ENFORCE_NO_UNUSED_HALS := false` in `BoardConfigCommon.mk` should also be removed at the same time.

---

### C6. `BOARD_VENDOR_RAMDISK_KERNEL_MODULES` missing despite `BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD` being set

```makefile
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := \
    msm_drm.ko
```
But there is **no** corresponding `BOARD_VENDOR_RAMDISK_KERNEL_MODULES` pointing to where the `.ko` file is located for the ramdisk.

**Impact:** The build system will try to load `msm_drm.ko` into the vendor ramdisk but won't know which file to copy there. `msm_drm.ko` needs to be present at first-stage boot (before `/vendor` is mounted) for display to work during init. Without it the display may not initialize during recovery or early boot stages.

**Fix:** Add:
```makefile
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := \
    $(COMMON_PATH)/prebuilts/msm_drm.ko
```

---

## 🟠 MAJOR — Will Cause Runtime Failures

### M1. ~~Vendor tree inherited in `rog5-common`~~ — ✅ Intentional (ROG 5 and 5s share vendor)

**Context confirmed by developer:** ROG Phone 5 and 5s share the same vendor partition (`vendor/asus/rog5s`). Inheriting `rog5s-vendor.mk` from the common tree is correct and intentional for this device family. ~~Not an issue.~~

---

### M2. `TARGET_CPU_VARIANT := cortex-a76` is wrong for Snapdragon 888

```makefile
TARGET_CPU_VARIANT := cortex-a76     # wrong
TARGET_2ND_CPU_VARIANT := cortex-a76 # wrong
```

SM8350 (Snapdragon 888) uses Cortex-X1 + A78 + A55 cores — **not** Cortex-A76. Every official LineageOS SM8350 device (e.g., `lemonade`, `kebab`) uses:
```makefile
TARGET_CPU_VARIANT := kryo
TARGET_2ND_CPU_VARIANT := generic
```

**Impact:** Compiler generates suboptimal instructions tuned for the wrong microarchitecture. Performance is degraded across the board; certain SIMD optimizations will be incorrect.

---

### M3. `BUILD_FINGERPRINT` is set using deprecated syntax

In `lineage_rog5s.mk`:
```makefile
BUILD_FINGERPRINT := asus/WW_I005D/ASUS_I005D:13/TKQ1.220807.001/33.0210.0210.200:user/release-keys
```

The `BUILD_FINGERPRINT :=` form is **deprecated** and only partially works in Android 13. The correct LineageOS standard is:
```makefile
PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildFingerprint=asus/WW_I005D/ASUS_I005D:13/TKQ1.220807.001/33.0210.0210.200:user/release-keys
```

Also: `ASUS_I005D` is the ROG Phone 5 model. The ROG Phone 5s is `ASUS_I005_1`. The fingerprint is wrong for `rog5s`.

---

### M4. `PRODUCT_BRAND` and `PRODUCT_MANUFACTURER` are lowercase in `lineage_rog5s.mk`

```makefile
PRODUCT_BRAND := asus          # should be ASUS
PRODUCT_MANUFACTURER := asus   # should be ASUSTeK
```

These values populate `ro.product.brand` and `ro.product.manufacturer`. The stock ASUS ROG firmware uses `ASUS` and `ASUSTeK`. Mismatched values cause:
- OEM unlock checks to fail.
- Play Integrity device verification to fail (wrong manufacturer string).
- Google Services activation issues.

---

### M5. `TARGET_DEVICE=ASUS_I005D` in `PRODUCT_BUILD_PROP_OVERRIDES` is wrong

```makefile
PRODUCT_BUILD_PROP_OVERRIDES += \
    TARGET_DEVICE=ASUS_I005D \
    TARGET_PRODUCT=WW_I005D
```

`TARGET_DEVICE` in build props should be the **Android device codename** (`rog5s`), not the OEM model number. Setting it to `ASUS_I005D` will cause:
- Incorrect `ro.product.device` value.
- OTA verification failures (OTA checks `ro.product.device` against the target).

**Fix:**
```makefile
PRODUCT_BUILD_PROP_OVERRIDES += \
    TARGET_DEVICE=rog5s \
    TARGET_PRODUCT=WW_I005D
```

---

### M6. Audio files use `$(LOCAL_PATH)` instead of `$(COMMON_PATH)` in `device.mk`

In `rog5-common/device.mk`:
```makefile
$(LOCAL_PATH)/audio/audio_effects.xml:...
$(LOCAL_PATH)/audio/audio_io_policy.conf:...
$(LOCAL_PATH)/audio/mixer_paths.xml:...
```

`LOCAL_PATH` is **not defined** in `device.mk` — it's a variable used in `Android.mk` files set by `$(call my-dir)`. In product makefiles (`.mk`) included via `inherit-product`, `LOCAL_PATH` is empty or undefined.

`COMMON_PATH` IS explicitly defined at the top of `device.mk`. The correct reference is `$(COMMON_PATH)/audio/...`.

**Impact:** Audio configuration XML files are not copied to vendor at build time. First boot will have no audio HAL config, causing `audioserver` crashes.

**Fix:** Replace all `$(LOCAL_PATH)/audio/` with `$(COMMON_PATH)/audio/`.  Also applies to: `$(LOCAL_PATH)/sensors/hals.conf`, `$(LOCAL_PATH)/configs/task_profiles.json`, `$(LOCAL_PATH)/hiddenapi-package-allowlist-product.xml`, etc.

---

### M7. `lineage.dependencies` is incomplete — missing `branch` for kernel and missing vendor

Current `rog5-common/lineage.dependencies`:
```json
[
  {
    "repository": "android_kernel_asus_sm8350",
    "target_path": "kernel/asus/sm8350"
  }
]
```

**Issues:**
1. No `branch` field for kernel — roomservice won't know which branch to clone.
2. No vendor entry — `breakfast rog5s` won't auto-clone `vendor/asus/rog5s`.
3. `rog5/` and `rog5s/` device trees have no `lineage.dependencies` referencing `rog5-common` — `breakfast rog5s` won't clone the common tree.

**Fix:**
```json
// rog5-common/lineage.dependencies
[
  {
    "repository": "android_kernel_asus_sm8350",
    "target_path": "kernel/asus/sm8350",
    "branch": "lineage-20.0"
  },
  {
    "repository": "android_vendor_asus_rog5s",
    "target_path": "vendor/asus/rog5s",
    "branch": "lineage-20.0"
  }
]

// rog5s/lineage.dependencies
[
  {
    "repository": "android_device_asus_rog5-common",
    "target_path": "device/asus/rog5-common",
    "branch": "lineage-20.0"
  }
]
```

---

## 🟡 MODERATE — LineageOS Standards Violations

### N1. `PRODUCT_NAME` / `PRODUCT_DEVICE` set in `device.mk` (wrong place)

```makefile
# device/asus/rog5s/device.mk
PRODUCT_NAME := lineage_rog5s
PRODUCT_DEVICE := rog5s
PRODUCT_MODEL := ASUS_I005D
PRODUCT_BRAND := ASUS
```

These should **only** be in `lineage_rog5s.mk`. Setting them in `device.mk` causes double-definition conflicts and breaks the LineageOS product separation model.

---

### N2. `VINTF_ENFORCE_NO_UNUSED_HALS := false` in `BoardConfigCommon.mk`

Silently allows HALs declared in `manifest.xml` to not be installed. Combined with `PRODUCT_ENFORCE_VINTF_MANIFEST := false`, this means **zero** HAL contract validation anywhere in the build. Will mask broken HAL declarations until runtime.

---

### N3. `NFC vendor inheritance` not guarded with `inherit-product-if-exists`

```makefile
$(call inherit-product, vendor/nxp/nfc/nfc-vendor-product.mk)
$(call inherit-product, vendor/nxp/secure_element/se-vendor-product.mk)
```

If the NXP vendor trees are not synced, the build will fail with "missing makefile". Should use `inherit-product-if-exists`.

---

### N4. `BOARD_MKBOOTIMG_ARGS` incomplete

```makefile
BOARD_MKBOOTIMG_ARGS := --header_version $(BOARD_BOOT_HEADER_VERSION)
```

Missing standard kernel offset arguments (`--dtb_offset`, `--kernel_offset`, `--ramdisk_offset`, `--tags_offset`, `--pagesize`). These are needed to correctly lay out the boot image memory map. If the bootloader expects specific offsets and the image uses defaults, it may not boot.

---

### N5. `out/` directory present in `device/asus/rog5s/`

The `out/` build artifact directory is present inside the device tree. It should never be committed to git. Add to `.gitignore`.

---

### N6. `PRODUCT_RO_FILE_SYSTEM ?= ext4` uses conditional assignment

```makefile
PRODUCT_RO_FILE_SYSTEM ?= ext4
```

The `?=` operator is non-standard in Android product makefiles and fragile. If another makefile sets this before device.mk is evaluated, the value here is silently ignored. Use `:=` or remove it (ext4 is the default anyway).

---

### N7. Security patch date hardcoded in `device.mk` instead of `lineage_*.mk`

```makefile
BOOT_SECURITY_PATCH := 2023-05-05
VENDOR_SECURITY_PATCH := $(BOOT_SECURITY_PATCH)
```

These belong in `lineage_rog5s.mk` / `lineage_rog5.mk` (product-level), not in the common `device.mk`. They affect `ro.vendor.build.security_patch` and should be updated per device independently.

---

## 🔵 MINOR / Bringup-Acceptable

### B1. HAL services named `*.rog5s` but live in `rog5-common`
All compiled HAL binaries (`vendor.lineage.touch@1.0-service.rog5s`, etc.) have `rog5s` in their name despite being in the common tree. Acceptable for bringup. Must be renamed to a common suffix before official submission.

### B2. `init.rog5s.rc` has manual USB configfs setup
The USB gadget configfs setup in `init.rog5s.rc` is redundant if the USB HAL is working correctly. For bringup it is acceptable to have it to ensure ADB works. Should be removed once standard USB HAL is confirmed functional.

### B3. `TARGET_USERIMAGES_USE_F2FS := true` but partition sizes use ext4
`TARGET_USERIMAGES_USE_F2FS` is set but filesystem types are all declared as `ext4`. These conflict — decide on one and be consistent. For bringup, ext4 is more stable.

### B4. Overlay packages named `ROG5S*` served from `rog5-common`
As noted before — acceptable for bringup, must be fixed for official submission.

---

## ✅ Things Done Correctly

- ✅ `TARGET_KERNEL_CONFIG := kirisakura_defconfig` — correct defconfig
- ✅ `TARGET_KERNEL_SOURCE := kernel/asus/sm8350` — source kernel build (no prebuilt)
- ✅ No `BOARD_KERNEL_SEPARATED_DTBO` — correct, using prebuilt DTBO
- ✅ `BOARD_VIRTUAL_AB_OTA := true` — correct for this device
- ✅ `PRODUCT_SHIPPING_API_LEVEL := 31` — correctly set
- ✅ `BOARD_USES_RECOVERY_AS_BOOT := true` — correct for this device's partition layout
- ✅ `TARGET_RECOVERY_FSTAB` points to `init/fstab.default` which exists
- ✅ AVB signing configured with correct rollback index locations
- ✅ Dynamic partitions correctly configured with `odm` included
- ✅ RFS symlinks and mount points correctly set in `Android.mk`
- ✅ `lineage.dependencies` references kernel (partially)
- ✅ HIDL manifest `target-level="6"` is correct for Android 13
- ✅ No duplicate variable declarations in the actual `BoardConfigCommon.mk`
- ✅ `BOOT_SECURITY_PATCH` and `VENDOR_SECURITY_PATCH` are at least set (wrong location but better than missing)

---

## 🎯 Priority Fix Order

```
1. [C1] Add core_64_bit.mk and full_base_telephony.mk to lineage_rog5.mk
2. [C4] Guard ro.adb.secure=0 with ifneq(TARGET_BUILD_VARIANT,user)
3. [C5] Remove PRODUCT_ENFORCE_VINTF_MANIFEST from common device.mk
4. [M6] Fix $(LOCAL_PATH) → $(COMMON_PATH) for audio and all other file copies
5. [M1] Move vendor inherit to device-specific device.mk files
6. [M7] Fix lineage.dependencies in all 3 trees
7. [C3] Initialize git in device/asus/rog5
8. [C2] Remove androidboot.selinux=permissive and buildvariant from BOARD_KERNEL_CMDLINE
9. [C6] Add BOARD_VENDOR_RAMDISK_KERNEL_MODULES
10. [M2] Fix CPU variant: cortex-a76 → kryo / generic
11. [M3/M4] Fix BUILD_FINGERPRINT style, PRODUCT_BRAND/MANUFACTURER case
12. [M5] Fix TARGET_DEVICE= in PRODUCT_BUILD_PROP_OVERRIDES
```
