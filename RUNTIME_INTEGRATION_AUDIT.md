# 🔬 Complete Runtime Integration Audit Report

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: August 3, 2026  
**Scope**: 5-area evidence-based audit per investigation protocol

---

## 1. ✅ Display HAL VINTF Registration Audit

### Composer Service (`vendor.qti.hardware.display.composer-service`)

**Vendor Manifest Fragment** advertises:
| HAL Name | Format | Transport | Version | Interface | Instance |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `android.hardware.graphics.composer` | HIDL | hwbinder | **2.4** | `IComposer` | `default` |
| `vendor.qti.hardware.display.composer` | HIDL | hwbinder | 3.0 | `IQtiComposer` | `default` |
| `vendor.display.config` | HIDL | hwbinder | 2.0 | `IDisplayConfig` | `default` |
| `vendor.display.color` | HIDL | hwbinder | 1.5 | `IDisplayColor` | `default` |
| `vendor.display.postproc` | HIDL | hwbinder | 1.0 | `IDisplayPostproc` | `default` |

**Allocator Service** advertises:
| HAL Name | Format | Transport | Version | Interface | Instance |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `android.hardware.graphics.allocator` | HIDL | hwbinder | 3.0, 4.0 | `IAllocator` | `default` |
| `vendor.qti.hardware.display.allocator` | HIDL | hwbinder | 3.0, 4.0 | `IQtiAllocator` | `default` |

**SurfaceFlinger Request** (from `frameworks/native/services/surfaceflinger/`):
- Requests `android.hardware.graphics.composer@2.4::IComposer/default` via hwbinder.

**Framework Compatibility Matrix (`compatibility_matrix.5.xml` - API level 31)**:
- Requires `android.hardware.graphics.composer@2.1-4::IComposer/default` (non-optional).

**Verdict**: ✅ **Interface, version, and instance names MATCH**. No VINTF inconsistency detected.

> [!NOTE]
> `PRODUCT_ENFORCE_VINTF_MANIFEST := false` is set in both `device.mk` and `lineage_rog5s.mk`. This disables VINTF enforcement at runtime. While this prevents VINTF mismatch panics, it also suppresses diagnostic errors that would otherwise be logged.

---

## 2. ⚠️ Linker Namespace Audit

- Android 12+ generates linker namespace configuration dynamically at runtime via `/system/bin/linkerconfig` tool executed during `early-init`.
- No pre-generated `ld.config.txt` is present in the normal boot partition (only in recovery and APEX).
- The `ld.config.txt` found at boot packaging path is the **recovery-mode linker config** (`dir.recovery = /system/bin`), not the runtime vendor namespace config.

**Implication**: The vendor namespace configuration (`[vendor]` section allowing vendor HALs to access VNDK libs) is generated fresh at every boot by `linkerconfig`. We cannot statically audit this from the build tree — it requires runtime execution or direct inspection from the device.

**What this means**: We cannot from static analysis confirm or deny that `vendor.qti.hardware.display.composer-service` has correct linker namespace access. This is a gap that can only be resolved with runtime logs.

---

## 3. ⚠️ SM8350 Reference Device Comparison

Only one SM8350 device tree is present in the build tree:
```
device/asus/rog5s/
```
No other SM8350 Lineage device tree (e.g., OnePlus 9, Mi 11, Moto Edge X30) is available for direct file comparison. A reference comparison would require fetching an external SM8350 Lineage 20 device tree.

---

## 4. 🔍 Boot vs. Recovery Ramdisk Comparison

### Key Structural Finding: Boot.img is Almost Empty

| Ramdisk | File Count | Contents |
| :--- | :--- | :--- |
| **`boot.img` ramdisk** | **1 file** | Only `system/etc/ramdisk/build.prop` |
| **`ramdisk-recovery.img`** | **169 files** | Full recovery init + `init.asus.recovery.rc`, `init.rc`, `ueventd.rc`, `recovery.fstab`, etc. |
| **`vendor_boot.img` ramdisk** | **22 files** | `first_stage_ramdisk/fstab.default`, `first_stage_ramdisk/fstab.emmc`, `system/bin/linker64`, `system/bin/e2fsck`, etc. |

This is **correct and expected** for Android 12+ with Boot Header v3. First-stage init for normal boot comes from `vendor_boot.img`, not `boot.img`. Recovery has its own self-contained ramdisk.

### `boot.img` Kernel Command Line
From `unpack_bootimg` output:
```
command line args: (EMPTY)
```
For Boot Header v3, the kernel cmdline is carried in `vendor_boot.img`, not `boot.img`.

### `vendor_boot.img` Kernel Command Line (confirmed present):
```
console=ttyMSM0,115200n8 androidboot.hardware=qcom androidboot.console=ttyMSM0
androidboot.memcg=1 lpm_levels.sleep_disabled=1
video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237
service_locator.enable=1 androidboot.usbcontroller=a600000.dwc3
swiotlb=0 loop.max_part=7 cgroup.memory=nokmem,nosocket
pcie_ports=compat iptable_raw.raw_before_defrag=1
ip6table_raw.raw_before_defrag=1
androidboot.bootdevice=1d84000.ufshc
androidboot.boot_devices=soc/1d84000.ufshc
msm_drm.dsi_display0=qcom,mdss_dsi_ams678_er2_fhd_plus_dsc_cmd:
buildvariant=userdebug buildvariant=userdebug    ← NOTE: DUPLICATED
```

> [!WARNING]
> `buildvariant=userdebug` appears **twice** in the vendor_boot kernel cmdline. This is a minor cosmetic issue but is worth noting. The last value wins in Linux kernel parameter parsing.

### `vendor_boot` `fstab.default` — First-Stage Mount Configuration
All standard dynamic partitions declared: `system`, `system_ext`, `product`, `vendor`, `odm`.
- Uses both `ext4` and `erofs` fallback entries (correct for Lineage 20).
- `/vendor/asusfw` partition declared with `slotselect` (ASUS-specific firmware partition).
- No `vendor_dlkm` entry present.

---

## 5. 🚨 Runtime Evidence Sources

### Current ADB Status
- ADB is **not available** from the build server (`adb: command not found`).
- ADB access must be performed from the Windows host with the phone connected.

### Available Runtime Evidence Sources (Requires Device Connection)

| Source | How to Collect | What It Shows |
| :--- | :--- | :--- |
| **pstore / ramoops** | `adb shell ls /sys/fs/pstore/` | Last kernel panic or crash log from prior boot |
| **init log** | `adb logcat -b all -d \| grep init` | First failing service at boot |
| **hwservicemanager log** | `adb logcat -b all -d \| grep hwservicemanager` | HAL registration events |
| **linker errors** | `adb logcat -b all -d \| grep "linker\|dlopen\|cannot locate"` | Dynamic library load failures |
| **tombstones** | `adb shell ls /data/tombstones/` | Native process crash reports |
| **dropbox** | `adb shell ls /data/system/dropbox/` | System service crash logs |
| **dmesg** | `adb shell dmesg` | Kernel driver initialization events |

> [!IMPORTANT]
> The only way to obtain runtime evidence for the hang at the ROG logo is to boot the device into a state where ADB is accessible. Since ADB is not available during the hang, the next step is either:
> 1. Enable early ADB via `persist.sys.usb.config=adb` in `build.prop` or `default.prop`.
> 2. Access pstore/ramoops from TWRP/recovery after the failed boot attempt.
> 3. Add kernel `earlycon` and collect serial console output.

---

## Summary of Findings

| Area | Status | Key Finding |
| :--- | :---: | :--- |
| **VINTF Display HAL Registration** | ✅ OK | Composer advertises `android.hardware.graphics.composer@2.4::IComposer/default`. Exact match with SurfaceFlinger request. |
| **Linker Namespace** | ⚠️ Inconclusive | `linkerconfig` is generated at runtime. Cannot statically audit vendor namespace access. |
| **SM8350 Reference Comparison** | ⚠️ Not possible | No other SM8350 device tree in the local build tree. |
| **Boot vs Recovery Ramdisk** | ✅ Structurally correct | Boot.img is intentionally minimal (header v3). vendor_boot carries cmdline and fstab. No anomalies. |
| **Runtime Evidence** | 🚨 Unavailable | ADB not accessible during hang. Pstore/tombstones require device connection from Windows host. |

### Net Conclusion

Static analysis has exhausted all checks confirmable from build artifacts:
- VINTF is internally consistent.
- ELF dependencies resolve (including APEX-provided libs).
- init rc configurations match CAF SM8350 reference.
- Ramdisk structure is correct for boot header v3.

**The next required step is runtime evidence collection from the device itself.**
