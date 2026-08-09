# 🐧 Comprehensive Kernel Audit & Compatibility Report

> **Repository:** [`kernel/asus/sm8350`](file:///mnt/android-build/kernel/asus/sm8350)  
> **Branch:** `lineage-20.0`  
> **Kernel Version:** Linux **5.4.210** (`Kleptomaniac Octopus`)  
> **Target SoC:** Qualcomm **SM8350 (Lahaina)** — ASUS ROG Phone 5 (ZS673KS) / 5s (ZS676KS)  
> **Defconfig:** `arch/arm64/configs/kirisakura_defconfig`  
> **Toolchain:** Clang 11.0.2 (`LLVM=1 LLVM_IAS=1`)  

---

## 📑 Executive Summary

The kernel tree `kernel/asus/sm8350` is **100% compatible** with the LineageOS device trees (`device/asus/rog5-common`, `device/asus/rog5s`, and `device/asus/rog5`). 

All kernel compilation flags, CPU architecture variants, display/GPU drivers, memory layout offsets, and Android 13 (LineageOS 20.0) requirements match the configuration in `BoardConfigCommon.mk`.

---

## 📊 Compatibility Matrix

| Property | Device Tree Requirement | Kernel Tree Configuration | Status |
|:---|:---|:---|:---:|
| **Source Path** | `kernel/asus/sm8350` | Matches source tree location | ✅ **Match** |
| **Config Target** | `kirisakura_defconfig` | `arch/arm64/configs/kirisakura_defconfig` | ✅ **Match** |
| **Architecture** | `arm64` (`armv8-2a-dotprod`) | `CONFIG_ARCH_QCOM=y`, `CONFIG_ARCH_LAHAINA=y`, `CONFIG_ARM64=y` | ✅ **Match** |
| **Target Board** | `lahaina` | `CONFIG_BOARD_ASUS_I005D=y` | ✅ **Match** |
| **Toolchain** | Clang + LLVM IAS | `CONFIG_CC_IS_CLANG=y`, `CONFIG_LD_IS_LLD=y` | ✅ **Match** |
| **LTO Optimization** | `KERNEL_LTO := thin` | `CONFIG_THINLTO=y`, `CONFIG_LTO_CLANG_THIN=y` | ✅ **Match** |
| **Display Stack** | `msm_drm` (Monolithic `Image`) | `CONFIG_DRM_MSM=y`, `CONFIG_MSM_EXT_DISPLAY=y` | ✅ **Match** |
| **GPU Driver** | Adreno / KGSL | `CONFIG_QCOM_KGSL=y` (Adreno 6xx series) | ✅ **Match** |
| **Storage & FS** | UFS / F2FS / ext4 | `CONFIG_SCSI_UFSHCD_QCOM=y`, `CONFIG_F2FS_FS=y`, `CONFIG_EXT4_FS=y` | ✅ **Match** |
| **Android IPC** | BinderFS / ASHMEM / ION | `CONFIG_ANDROID_BINDER_IPC=y`, `CONFIG_ANDROID_BINDERFS=y`, `CONFIG_ION=y` | ✅ **Match** |
| **Boot Header** | Version `3`, Page size `4096` | Header v3 / 4K page size verified | ✅ **Match** |

---

## 🛠️ Resolved Build Issues

### `msm_drm.ko` Module Misconfiguration (Fixed)
- **Problem:** `BoardConfigCommon.mk` originally attempted to stage `msm_drm.ko` as a loadable vendor ramdisk module (`$(COMMON_PATH)/prebuilts/msm_drm.ko`). However, that file did not exist on disk, which would cause `make` to fail.
- **Kernel Discovery:** In `kirisakura_defconfig`, `CONFIG_DRM_MSM=y` compiles DRM display support statically into the primary kernel binary `Image`, making loadable `.ko` modules unnecessary.
- **Action Taken:** `msm_drm.ko` module references were removed from `BoardConfigCommon.mk` and committed/pushed to origin (`b0baabe`).

---

## ✨ Features & Extensions in Kernel

The Kirisakura kernel includes several advanced performance and security extensions:

1. **KernelSU & SUSFS Integration:**
   - `CONFIG_KSU=y` & `CONFIG_KSU_SUSFS=y` built-in for root access and kernel-level overlay hiding.
2. **WireGuard Support:**
   - `CONFIG_WIREGUARD=y` for kernel-accelerated VPN tunnels.
3. **Task Scheduling:**
   - Qualcomm WALT scheduler (`CONFIG_SCHED_WALT=y`) paired with `schedutil` governor.
4. **Security Enhancements:**
   - Control Flow Integrity (`CONFIG_CFI_CLANG=y`), Shadow Call Stack (`CONFIG_SHADOW_CALL_STACK=y`), and KASLR (`CONFIG_RANDOMIZE_BASE=y`).

---

## 📌 DTB / DTBO Handling

- **Boot packaging:** Both `device/asus/rog5s` and `device/asus/rog5` use prebuilt `dtbo.img` and `dtb` files stored in their respective `prebuilts/` directories.
- **Prebuilt Status:**
  - `device/asus/rog5s/prebuilts/dtbo.img` (8,388,608 bytes) — Present ✅
  - `device/asus/rog5/prebuilts/dtbo.img` (8,388,608 bytes) — Present ✅

---

## ⚠️ Advisory

> [!WARNING]
> In `.git/config` of `/mnt/android-build/kernel/asus/sm8350`, an active GitHub Personal Access Token (PAT) is hardcoded in the remote URL. 
> 
> Recommend updating the remote URL to SSH or revoking the token if necessary.
