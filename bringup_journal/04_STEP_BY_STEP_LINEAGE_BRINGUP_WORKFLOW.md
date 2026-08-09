# 🛠️ Part 4: Step-by-Step LineageOS 20.0 Bringup Workflow

This document provides a comprehensive, step-by-step master workflow detailing how LineageOS 20.0 (Android 13) was brought up on the **ASUS ROG Phone 5 series (`sm8350`)** from stock firmware to an official commonized architecture.

---

## 📌 Phase 1: Stock Firmware Analysis & Dump Extraction
1. **Unpack Stock Firmware:** Extracted stock payload/images from ASUS official firmware `33.0210.0210.200`.
2. **Extract DTB / DTBO:** Extracted devicetree blobs (`lahaina.dtb` and `dtbo.img`) from stock `boot.img` and `vendor_boot.img`.
3. **Generate Vendor Proprietary List:** Extracted binary list for cameras, sensors, audio, and radio firmware into `proprietary-files.txt`.

---

## 📌 Phase 2: Device Tree Skeleton Creation
1. **Create Base Structure:** Built directory tree `device/asus/rog5s`.
2. **Define Product Makefiles:**
   * `AndroidProducts.mk` -> Exposes `lineage_rog5s-userdebug` lunch target.
   * `lineage_rog5s.mk` -> Defines `PRODUCT_NAME := lineage_rog5s` and `PRODUCT_MODEL := ASUS_I005D`.
   * `BoardConfig.mk` -> Configures partition sizes, kernel cmdline, and AVB rules.
   * `device.mk` -> Inherits common device packages and vendor makefile (`rog5s-vendor.mk`).

---

## 📌 Phase 3: Kernel Integration & DRM Driver Module Setup
1. **Set Up Kernel Tree:** Integrated Kirisakura kernel source into `kernel/asus/sm8350`.
2. **Configure Defconfig:** Used `kirisakura_defconfig` for Snapdragon 888+ SM8350 platform support.
3. **Display Driver Module:** Built `msm_drm.ko` vendor display driver module from source and declared auto-loading in `BoardConfig.mk`:
   ```makefile
   BOARD_VENDOR_KERNEL_MODULES_LOAD := msm_drm.ko
   ```

---

## 📌 Phase 4: AVB Signing & VINTF Alignment
1. **AVB Metadata Configuration:** Configured LineageOS standard RSA-4096 test keys in `BoardConfig.mk` to prevent bootloader hash verification halts (`AVB_HASH_ERROR`).
2. **VINTF Compatibility Matrix:** Aligned HAL versions in `manifest.xml` and `vendor_framework_compatibility_matrix.xml` for HIDL audio, camera, fingerprint, fastcharge, and touch interfaces.

---

## 📌 Phase 5: Display HAL & Graphics Subsystem Migration
1. **Diagnose Display Black Screen:** Identified that proprietary OEM display HAL binaries (`composer-service`, `allocator-service`) crashed due to binder interface incompatibilities in Android 13.
2. **Migrate to Open-Source CAF Display HAL:** Replaced proprietary display blobs with upstream open-source LineageOS CAF HAL (`hardware/qcom-caf/sm8350/display` branch `lineage-20.0-caf-sm8350`).
3. **Compile Un-Blobbed Vendor Image:** Verified clean build with `m vendorimage` generating a 100% open-source 1.2GB `vendor.img`.

---

## 📌 Phase 6: Legacy Code Purge & Model Alignment
1. **Purge Zenfone 8 (`sake`) Remnants:** Deleted 11 orphaned `.rc` and `.xml` files carried over from Zenfone 8 bringup.
2. **Rename Overlays:** Renamed all 8 resource overlay packages to match the device series (`ROG5SFrameworks`, `ROG5SSystemUI`, etc.).
3. **Fix Model Identifiers:**
   * Updated `config_mms_user_agent` to `ZS676KS`.
   * Updated ACDB audio calibration directory references to `ZS673KS`.

---

## 📌 Phase 7: Commonization Architecture (`rog5-common`)
1. **Create Common Tree:** Created `device/asus/rog5-common` to hold 95% of shared platform code (`overlay/`, `hidl/`, `sepolicy/`, `init/`, `touch/`, `fingerprint/`, `vibrator/`, `fastcharge/`, `livedisplay/`, `sensors/`).
2. **Slim Down Device Trees:**
   * Refactored `device/asus/rog5s` into a slim (<15 lines) makefile set inheriting `rog5-common`.
   * Created `device/asus/rog5` into a slim (<15 lines) makefile set inheriting `rog5-common`.
3. **Verify Build Evaluation:** Verified that both `lunch lineage_rog5s-userdebug` and `lunch lineage_rog5-userdebug` evaluate cleanly with Code 0.

---

## 📌 Phase 8: GitHub Synchronization & Release
Pushed clean code to GitHub remotes:
* 🌐 [`android_device_asus_rog5-common`](https://github.com/sibinsilva/android_device_asus_rog5-common)
* 🌐 [`android_device_asus_rog5s`](https://github.com/sibinsilva/android_device_asus_rog5s)
* 🌐 [`android_device_asus_rog5`](https://github.com/sibinsilva/android_device_asus_rog5)
* 🌐 [`android_vendor_asus_rog5s`](https://github.com/sibinsilva/android_vendor_asus_rog5s)
* 🌐 [`android_kernel_asus_sm8350`](https://github.com/sibinsilva/android_kernel_asus_sm8350)
* 🌐 [`lineageos-rog5s-bringup-docs`](https://github.com/sibinsilva/lineageos-rog5s-bringup-docs)
