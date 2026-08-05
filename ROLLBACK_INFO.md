# Kernel Migration Rollback State

This document records the exact state of the LineageOS kernel build environment prior to the migration to the Kirisakura (ASUS ROG) kernel source tree.

## 1. Current Git Commit
* **Repository:** `https://github.com/LineageOS/android_kernel_asus_sm8350.git`
* **Branch:** `lineage-20`
* **HEAD Commit:** `9797389ec560273a06391bd5b9071a2c75328faf` (drivers: sensors: ASH: Fix permissions for pocket_en node)

## 2. Current BoardConfig.mk
* **File:** `/mnt/android-build/device/asus/rog5s/BoardConfig.mk`
* **Line 81:** `TARGET_KERNEL_CONFIG := vendor/sake_defconfig vendor/rog5s.config`

## 3. Current Kernel Configuration & Build Command
* **Build Command:** `make ARCH=arm64 O=out vendor/sake_defconfig vendor/rog5s.config`
* **Base Defconfig:** `vendor/sake_defconfig` (Zenfone 8)
* **Configuration State:** The generated `.config` resulted in `CONFIG_MACH_ASUS_SAKE=y` and `CONFIG_MACH_ASUS_ZS673KS` completely missing due to missing upstream dependencies in the source tree.

## 4. Preservation Actions Taken
* The original LineageOS source tree at `/mnt/android-build/kernel/asus/sm8350` was **moved and preserved** as `/mnt/android-build/kernel/asus/sm8350_lineage_backup`.
* If a rollback is necessary, simply delete the new `sm8350` directory, rename the backup to `sm8350`, and restore `BoardConfig.mk` line 81 to `vendor/sake_defconfig vendor/rog5s.config`.
