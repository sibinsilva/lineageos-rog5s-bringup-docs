# Executive Bring-Up & Pre-Flash Verification Report

> **Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ZS673KS` / `sm8350`)  
> **Build Target**: `bootimage` & `vendorbootimage` (LineageOS 20 / Android 13)  
> **Kernel Tree**: Kirisakura (`ANAKIN_ROG5`)  
> **Compiler**: Clang 14.0.7 with LLVM Integrated Assembler (`LLVM_IAS=1`)  
> **Build Status**: **SUCCESSFUL (`0 errors`, `0 warnings`)**

---

## 1. Summary of Accomplishments

1. **Kernel Tree Migration**: Replaced incomplete Lineage kernel tree with Kirisakura `ANAKIN_ROG5` tree (original tree preserved at `kernel/asus/sm8350_lineage_backup`).
2. **Clang 14 Modernization**:
   - Fixed GCC local register asm conflicts in `arch/arm64/include/asm/vdso/gettimeofday.h`.
   - Updated OpenSSL 3.0 compatibility in `scripts/extract-cert.c`.
   - Resolved inline asm constraints in `kgdb.h` and `stack_pointer.h`.
   - Fixed target triple (`--target=aarch64-linux-gnu`) via `KERNEL_CLANG_TRIPLE` and `CROSS_COMPILE`.
3. **OEM Monolithic Reconstruction**:
   - Identified that `scripts/kconfig/Makefile` treated `_defconfig` fragments by wiping `.config`. Fixed fragment merge by using `vendor/ZS673KS-perf.config`.
   - Restored 32 Qualcomm & ASUS parent drivers from GKI modular (`=m`) to built-in (`=y`) matching OEM `stock_defconfig`.
4. **Build Completion**:
   - **`vmlinux` Linker**: 0 undefined symbols, 0 duplicate symbols.
   - **Kernel Modules (`MODPOST`)**: 184 modules compiled and post-processed with 0 errors.

---

## 2. Generated Artifacts & Hashes

| Image File | Size | SHA-256 Checksum | Path |
|:---|:---|:---|:---|
| **`boot.img`** | 96 MB (`100,663,296` B) | `419e2a2183aa1e5df7ddeba017204665cbeb636c33c014d7f51f1eb5315499f0` | `out/target/product/rog5s/boot.img` |
| **`vendor_boot.img`** | 96 MB (`100,663,296` B) | `ea937d9b85d4c0a09fc71296e4b0b409303bdc0268474f305dddad3602a4e33c` | `out/target/product/rog5s/vendor_boot.img` |
| **`kernel` (`Image`)** | 47 MB (`48,619,520` B) | `a2aa02c6ad433eddea521b104904f1798dbf9f015e90d4aa0747f3662fe6b46c` | `out/target/product/rog5s/kernel` |

---

## 3. Pre-Flash Verification Check Results

| Verification Check | Result | Verification Detail |
|:---|:---:|:---|
| **1. Linker Integrity** | ✅ PASSED | `vmlinux` linked with **0 undefined symbols** and **0 duplicate symbols**. |
| **2. Kconfig Audit** | ✅ PASSED | `ZS673KS-perf.config` matches OEM `stock_defconfig` built-in settings. `CONFIG_KSU` disabled, `CONFIG_BUILD_ARM64_DT_OVERLAY` disabled. |
| **3. Output File Creation** | ✅ PASSED | `Image`, `boot.img`, and `vendor_boot.img` produced in target output dir. |
| **4. First-Stage `fstab`** | ✅ PASSED | Unpacked `vendor_boot.img` ramdisk; verified `first_stage_ramdisk/fstab.default` is present and contains `/system`, `/vendor`, `/product`, `/odm`, `/data` mounts. |
| **5. Packaging Layout** | ✅ PASSED | Header Version 3, Load Address `0x8000`, DTB (1.43 MB) baked into header. |
| **6. DTBO Preservation** | ✅ PASSED | `BOARD_KERNEL_SEPARATED_DTBO` disabled — device OEM `dtbo` partition remains untouched. |

---

## 4. Flashing Instructions & Observation Plan

### Fastboot Flash Commands
```bash
# 1. Put device into Fastboot mode (Hold Vol Down + Power)

# 2. Flash restored vendor_boot.img (contains first-stage fstab.default)
fastboot flash vendor_boot out/target/product/rog5s/vendor_boot.img

# 3. Flash custom Kirisakura boot.img (contains source-built Image)
fastboot flash boot out/target/product/rog5s/boot.img

# 4. Reboot device
fastboot reboot
```

### Runtime Observation Protocol
1. **ASUS ROG Splash**: Note duration (in seconds) of Republic of Gamers logo.
2. **Display State**: Observe if screen turns black/off or remains lit.
3. **Vibration**: Check for haptic vibration during boot sequence.
4. **USB Enumeration**: Check `lsusb`, `adb devices`, and `fastboot devices`.
5. **Slot Status**: Run `fastboot getvar current-slot`, `slot-successful`, `slot-unbootable`.
