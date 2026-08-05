# Complete Pre-Flash Verification Report (ROG Phone 5S `boot.img` & `vendor_boot.img`)

> **Build Status**: **SUCCESSFUL (`0 errors`)**  
> **Target**: ASUS ROG Phone 5S (`ZS676KS` / `ZS673KS` / `sm8350`)  
> **Kernel Source**: Kirisakura (`ANAKIN_ROG5`) merged kernel tree  
> **Compiler**: Clang 14.0.7 (`LLVM_IAS=1`) under LineageOS 20 (Android 13)

---

## 1. Linker Integrity Check
- **`vmlinux` Main Kernel Link**: **PASSED** (0 undefined symbols, 0 duplicate symbols)
- **Module Link (`MODPOST`)**: **PASSED** (All loadable modules post-processed cleanly without missing symbol exports)

---

## 2. Final `.config` Audit & OEM `stock_defconfig` Comparison

The final generated configuration matches the intended OEM monolithic built-in architecture. Key deviations from OEM `stock_defconfig` are categorized below:

### A. Intentional Build-System / Modernization Differences
- **`LLVM_IAS=1`**: Integrated LLVM assembler enabled for Clang 14 compilation.
- **`CONFIG_KSU`**: Disabled (`# CONFIG_KSU is not set`) to ensure clean stock kernel baseline without root hooks.
- **`CONFIG_BUILD_ARM64_DT_OVERLAY`**: Disabled (`# CONFIG_BUILD_ARM64_DT_OVERLAY is not set`) per Option A decision (preserves stock OEM DTBO partition untouched).

### B. Restored OEM Monolithic Driver Built-ins (`=y`)
All 32 Qualcomm and ASUS hardware drivers that were modularized in GKI defaults have been restored to built-in (`=y`) matching `stock_defconfig`:
- **Core Subsystems**: `QCOM_LLCC`, `QCOM_KGSL_IOMMU`, `QSEECOM`, `QCOM_GLINK`, `QCOM_PDC`, `QCOM_SOCINFO`, `QPNP_PBS`
- **Power & Charging**: `QTI_PMIC_GLINK`, `QTI_BATTERY_CHARGER`, `QTI_ADC_TM`, `INPUT_QCOM_HV_HAPTICS`, `LEDS_QTI_FLASH`
- **USB & Storage**: `USB_DWC3`, `SCSI_UFS_CRYPTO_QTI`, `USB_REDRIVER_NB7VPQ904M`, `MMC_CQHCI_CRYPTO`
- **Display & Security**: `QTI_ALTMODE_GLINK`, `QTI_CRYPTO_COMMON`, `QTI_HW_KEY_MANAGER`

---

## 3. Generated Image Artifacts & Metadata

| Image File | Size | SHA-256 Hash | Path |
|:---|:---|:---|:---|
| **`boot.img`** | 96 MB (`100,663,296` B) | `419e2a2183aa1e5df7ddeba017204665cbeb636c33c014d7f51f1eb5315499f0` | `out/target/product/rog5s/boot.img` |
| **`vendor_boot.img`** | 96 MB (`100,663,296` B) | `ea937d9b85d4c0a09fc71296e4b0b409303bdc0268474f305dddad3602a4e33c` | `out/target/product/rog5s/vendor_boot.img` |
| **`kernel` (`Image`)** | 47 MB (`48,619,520` B) | `a2aa02c6ad433eddea521b104904f1798dbf9f015e90d4aa0747f3662fe6b46c` | `out/target/product/rog5s/kernel` |

---

## 4. `vendor_boot.img` First-Stage `fstab.default` Inspection

Unpacked `vendor_boot.img` using `unpack_bootimg` and verified vendor ramdisk structure:

- **Vendor Ramdisk Location**: `first_stage_ramdisk/fstab.default`
- **Generation Source**: LineageOS build system (`BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true`)
- **Key Mount Entries Verified**:
  - `system` (`/system`, ext4/erofs, `first_stage_mount`, `logical`)
  - `system_ext` (`/system_ext`, ext4/erofs, `first_stage_mount`, `logical`)
  - `product` (`/product`, ext4/erofs, `first_stage_mount`, `logical`)
  - `vendor` (`/vendor`, ext4/erofs, `first_stage_mount`, `logical`)
  - `odm` (`/odm`, ext4/erofs, `first_stage_mount`, `logical`)
  - `userdata` (`/data`, f2fs, `inlinecrypt`, `fileencryption=aes-256-xts...`)
  - `asusfw` (`/vendor/asusfw`, ext4, `slotselect`)

---

## 5. Boot / Vendor Boot Packaging Layout

- **Header Version**: `3` (Android 12/13 header layout)
- **Kernel Load Address**: `0x00008000`
- **Vendor Ramdisk Size**: `3,239,576 bytes` (gzip compressed cpio)
- **Vendor Command Line**:
  `console=ttyMSM0,115200n8 androidboot.hardware=qcom androidboot.console=ttyMSM0 androidboot.memcg=1 lpm_levels.sleep_disabled=1 service_locator.enable=1 androidboot.usbcontroller=a600000.dwc3 buildvariant=userdebug`
- **DTB**: `1,429,937 bytes` (baked directly into `vendor_boot.img` header)
- **DTBO**: `BOARD_KERNEL_SEPARATED_DTBO` disabled — existing DTBO partition on device remains 100% untouched.

---

## 6. Flash Execution & Observation Protocol

When flashing the newly built images:

```bash
# 1. Boot ROG Phone 5S into Fastboot mode (Hold Vol Down + Power)
# 2. Flash vendor_boot.img (restores first-stage fstab.default)
fastboot flash vendor_boot out/target/product/rog5s/vendor_boot.img

# 3. Flash boot.img (contains Kirisakura ANAKIN_ROG5 kernel Image)
fastboot flash boot out/target/product/rog5s/boot.img

# 4. Reboot
fastboot reboot
```

### Observation Checklist
1. **ASUS Splash Duration**: Does it show the ROG Republic of Gamers logo? Note how many seconds before display changes.
2. **Display & Backlight**: Does display turn off/black after logo, or stay illuminated?
3. **Vibration**: Is there a haptic vibration upon boot?
4. **USB Enumeration**:
   - `lsusb` output (check for `0b05:` ASUS vendor ID or Qualcomm DIAG/ADB ID `05c6:`)
   - `adb devices`
   - `fastboot devices`
5. **Fastboot Slot Status**:
   - `fastboot getvar current-slot`
   - `fastboot getvar slot-successful:<current_slot>`
   - `fastboot getvar slot-unbootable:<current_slot>`
