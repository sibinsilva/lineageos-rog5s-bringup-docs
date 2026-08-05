# 🔬 Kernel Artifact-Level Comparison Report

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: July 31, 2026  
**Comparison Target**: Known-Working Standalone Kirisakura Kernel Binary (`v3.3.0-legacy-susfs`) vs. LineageOS 20.0 Compiled Kernel Binary

---

## 📑 Executive Summary

By extracting the embedded `ikconfig` payload directly from the known-working standalone Kirisakura kernel artifact (`Image.gz` extracted from `Kirisakura-ANAKIN-ROG5-KSU-Next-v3.3.0-legacy-susfs-july2026.zip`) and analyzing both binaries at the ARM64 header, size, build toolchain, and Kconfig levels, we identified three major structural divergences between the working kernel and the Lineage-produced kernel:

1. **LTO Mode Mismatch**: The working Kirisakura kernel **was compiled with ThinLTO enabled** (`CONFIG_THINLTO=y` / `CONFIG_LTO_CLANG=y`), whereas Controlled Experiment #2 disabled LTO.
2. **Panic-on-Warning Debug Flags**: The Lineage build enabled **5 strict `PANIC_ON_*` debug flags** (such as `CONFIG_EDAC_KRYO_ARM64_PANIC_ON_CE=y`) that cause the kernel to reboot on minor correctable CPU cache or scheduler warnings. These options are **disabled (`=n`)** in the working Kirisakura build.
3. **Early Memory Allocation Footprint**: The working Kirisakura kernel binary is **13.0 MB larger** on disk and allocates **15.3 MB more RAM** during early boot (`image_size = 0x04535000` vs `0x035f4000`).

---

## 🛠️ Priority 1: Build Environment Comparison

| Parameter | Working Standalone Kirisakura Build | LineageOS 20.0 Build Environment | Status |
| :--- | :--- | :--- | :---: |
| **Compiler Version** | Clang 14.0.7 (`clang-r450784e`) | Clang 14.0.6 (`clang-r450784d`) | Minor Patch Rev |
| **Linker Version** | LLD 14.0.7 | LLD 14.0.6 | Minor Patch Rev |
| **Target Defconfig** | `kirisakura_defconfig` | `stock_defconfig` + Lineage fragments | Config Base Diff |
| **Output Image Format** | `Image.gz` (GZIP Wrapper) | `Image` (Uncompressed Raw ARM64) | Wrapper Diff |
| **GCC Toolchain Triple** | `aarch64-linux-android-` (GCC 4.9) | `aarch64-linux-gnu-` | Triple Diff |

---

## ⚙️ Priority 2: Embedded `ikconfig` Symbol Analysis

Extracted embedded `ikconfig` from the working kernel binary using `scripts/extract-ikconfig`:

- **Working Kirisakura Total Symbols**: `5,468`
- **Lineage Build Total Symbols**: `5,508`

### 1. LTO Configuration
- **Working Kirisakura**: `CONFIG_LTO_CLANG=y` & `CONFIG_THINLTO=y` (ThinLTO Active)
- **Lineage Build**: `CONFIG_LTO_NONE=y`

> [!IMPORTANT]
> The working Kirisakura standalone kernel binary **was built with ThinLTO active**. Disabling LTO in Controlled Experiment #2 introduced a divergence from the working Kirisakura binary.

### 2. 🚨 Critical `PANIC_ON_*` Debug Switches
The Lineage build system enabled 5 strict hardware debug panic switches that are **disabled (`=n`)** in the working Kirisakura build:

```ini
# Enabled in Lineage Build (=y), Disabled in Working Kirisakura (=n):
CONFIG_EDAC_KRYO_ARM64_PANIC_ON_CE=y
CONFIG_EDAC_PANIC_ON_CE=y
CONFIG_EDAC_QCOM_LLCC_PANIC_ON_CE=y
CONFIG_PANIC_ON_SCHED_BUG=y
CONFIG_PANIC_ON_RT_THROTTLING=y
```

> [!WARNING]
> `CONFIG_EDAC_KRYO_ARM64_PANIC_ON_CE=y` forces an instant kernel panic if a correctable Kryo CPU L1/L2 cache error occurs during early driver initialization.

---

## 📦 Priority 3: Kernel Artifact Binary Breakdown

| Parameter | Working Kirisakura Image | Lineage-Produced Image | Comparison |
| :--- | :--- | :--- | :---: |
| **ARM64 Header Magic** | `0x644d5241` (`ARM\x64`) | `0x644d5241` (`ARM\x64`) | ✅ **IDENTICAL** |
| **ARM64 Text Offset** | `0x80000` (`512 KB`) | `0x80000` (`512 KB`) | ✅ **IDENTICAL** |
| **ARM64 Flags** | `0xa` (Little-Endian, 4KB page) | `0xa` (Little-Endian, 4KB page) | ✅ **IDENTICAL** |
| **Header `image_size`** | `0x04535000` (**`69.2 MB`**) | `0x035f4000` (**`53.9 MB`**) | ❌ **15.3 MB RAM Diff** |
| **File Size (Uncompressed)**| **`58,290,688 bytes`** (`55.6 MB`)| **`44,655,104 bytes`** (`42.6 MB`)| ❌ **13.0 MB Disk Diff** |
| **SHA-256 Digest** | `0934ed6ddfb4405b52f756a8d5f6b...` | `68a6920a4e22a1466c981fef41aa...` | Distinct Artifacts |
| **Appended DTB** | `False` | `False` | ✅ **BOTH NONE** |
| **Appended CPIO Payload** | `True` (IKCONFIG) | `True` (IKCONFIG) | ✅ **BOTH IKCONFIG** |

---

## 📊 Structural Summary & Next Steps

1. **Memory Footprint**: The working Kirisakura kernel is 13 MB larger and requests 15.3 MB more early-boot BSS memory allocation (`image_size`).
2. **LTO Restoration**: Restore `CONFIG_THINLTO=y` to match the working Kirisakura kernel.
3. **Debug Panic Removal**: Disable the 5 `PANIC_ON_*` debug switches in Lineage configuration to prevent early hardware watchdog panics.
