# 🐛 Part 2: Technical Issues, Root Cause Analysis & Rectifications

## Issue 1: Android Verified Boot (AVB) Hash Verification Failure
* **Symptom:** Device failed to boot beyond bootloader; AVB hash mismatch errors reported on `boot.img` and `vendor_boot.img`.
* **Root Cause:** Incomplete AVB metadata signing rules and missing `BOARD_AVB_VBMETA_SYSTEM` location index definitions in the device BoardConfig.
* **Rectification:** Added standard LineageOS AVB signing rules to `BoardConfigCommon.mk`:
  ```makefile
  BOARD_AVB_VBMETA_SYSTEM := product system system_ext
  BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA4096
  BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
  BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
  BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2
  ```

---

## Issue 2: Blank Screen / Bootloop due to Display HAL Conflicts
* **Symptom:** System booted into userspace but display remained completely black / blank.
* **Root Cause:** Conflict between prebuilt proprietary Qualcomm display binaries in `vendor/asus/rog5s` and open-source HALs. The proprietary `composer-service` crashed on startup due to missing binder interfaces in AOSP 13.
* **Rectification:** Purged proprietary display blobs from `vendor/asus/rog5s`. Switched to upstream open-source LineageOS CAF Display HAL (`hardware/qcom-caf/sm8350/display`) on branch `lineage-20.0-caf-sm8350`.

---

## Issue 3: Zenfone 8 (`sake`) Legacy Code & Overlay Mismatches
* **Symptom:** System properties and MMS user agent string reported Zenfone 8 model (`ZS590KS`) instead of ROG Phone 5 / 5s (`ZS673KS` / `ZS676KS`).
* **Root Cause:** Residual file artifacts copied from Zenfone 8 (`sake`) bringup trees.
* **Rectification:**
  1. Purged 11 orphaned Zenfone 8 init scripts and service files.
  2. Renamed 8 resource overlays from `Zenfone8...` to `ROG5S...` (`ROG5SFrameworks`, `ROG5SSystemUI`, `ROG5SSettings`, etc.).
  3. Corrected MMS user agent string in `config.xml` to `ZS676KS`.
  4. Updated ACDB audio data paths in `proprietary-files.txt` from `ZS590KS` to `ZS673KS`.

---

## Issue 4: Roomservice Search Failure on `lunch lineage_rog5-userdebug`
* **Symptom:** `lunch lineage_rog5-userdebug` failed with error `Device rog5 not found`.
* **Root Cause:** `BoardConfigCommon.mk` set `TARGET_ARCH := arm64` but was missing explicit 64-bit and 32-bit application support flags, causing Soong board evaluation to abort.
* **Rectification:** Added architecture support flags to `BoardConfigCommon.mk`:
  ```makefile
  TARGET_SUPPORTS_32_BIT_APPS := true
  TARGET_SUPPORTS_64_BIT_APPS := true
  ```

---

## Issue 5: Hardcoded Device Paths in Common Makefiles
* **Symptom:** `rog5` build target inherited hardcoded `device/asus/rog5s/` paths from `BoardConfigCommon.mk`.
* **Root Cause:** `TARGET_FS_CONFIG_GEN` and prebuilt DTB paths were explicitly hardcoded to `rog5s` instead of using dynamic variables.
* **Rectification:**
  1. Updated `TARGET_FS_CONFIG_GEN` to `$(COMMON_PATH)/config.fs`.
  2. Removed `BOARD_PREBUILT_DTBIMAGE_DIR` from `BoardConfigCommon.mk` so each device tree (`rog5s` / `rog5`) manages its own kernel prebuilts.
  3. Expanded `Android.mk` target filter to `ifneq ($(filter rog5 rog5s,$(TARGET_DEVICE)),)`.
