# 🔬 Runtime dmesg Analysis Report — Android Boot Evidence

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: August 3, 2026  
**Source**: `dmesg_android_boot.txt` captured from device ring buffer after hung Android boot  
**Kernel**: `5.4.210-qgki-perf #17 SMP PREEMPT Mon Aug 3 09:52:10 UTC 2026`

---

## 📑 Summary of Concrete Findings (Evidence Only)

| # | Finding | Lines | Severity |
|:---:|:---|:---:|:---:|
| 1 | **DRM display stack binds successfully at kernel level** | 1541, 1547, 1622 | ✅ OK |
| 2 | **`init: [libfs_avb]Failed to verify vbmeta digest`** | 1689-1690 | ⚠️ Warning |
| 3 | **`init: DM_DEV_STATUS failed for system_ext_b / product_b`** | 1773-1776 | ⚠️ Warning |
| 4 | **`init: Error: Apex SEPolicy failed signature check`** | 1779 | ⚠️ Non-fatal |
| 5 | **`/system/etc/selinux/apex/SEPolicy.zip: No such file or directory`** | 1781 | ⚠️ Non-fatal fallback |
| 6 | **`/dev/selinux/apex_property_contexts: No such file or directory`** | 1795 | ⚠️ Non-fatal |
| 7 | **`ueventd: Unable to read config file '/vendor/etc/ueventd.rc'`** | 1827 | 🚨 **MISSING FILE** |
| 8 | **`ipa_fws.mdt: Failed to locate`** (continuous loop) | 2088-2197 | 🟡 Continuous retry |
| 9 | **`snt8100fsr.image: Unable to open firmware file`** | 2147 (approx) | 🟡 Non-critical grip sensor |

---

## 🔍 Detailed Evidence Analysis

### 1. ✅ DRM Display Stack — Kernel Level (WORKING)

```
[2.169416] msm_drm: bound soc:qcom,smmu_sde_unsec_cb
[2.169492] dsi_display_bind: Successfully bind display panel 'qcom,mdss_dsi_ams678_er2_fhd_plus_dsc_cmd'
[2.169550] msm_drm ae00000.qcom,mdss_mdp: bound soc:qcom,dsi-display-primary
[2.169554] msm_drm ae00000.qcom,mdss_mdp: bound soc:qcom,dsi-display-secondary
[2.171243] [drm] Initialized msm_drm 1.4.0 20130625 for ae00000.qcom,mdss_mdp on minor 0
```

**Observation**: The kernel DRM driver successfully binds all display components including the primary DSI display with panel `ams678`. The display pipeline is functional at the kernel level.

> [!NOTE]
> The repeated `OF: graph: no port node found in /soc/qcom,dsi-display-primary` errors at `t=1.206s` are **deferred probe** messages during component registration. They are resolved when `dsi-ctrl-0` and `dsi-ctrl-1` probe successfully at `t=2.156s`. This is normal Linux device model behavior, not a failure.

---

### 2. ⚠️ AVB / vbmeta Digest Verification Warning

```
[2.227773] init: [libfs_avb]Invalid hash size:
[2.227777] init: [libfs_avb]Failed to verify vbmeta digest
```

**Observation**: `init` fails to verify the vbmeta digest during first-stage mount. This is consistent with the bootloader state `androidboot.verifiedbootstate=orange` (present in kernel cmdline), which indicates unlocked bootloader with custom signing. Init continues past this.

---

### 3. ⚠️ DM_DEV_STATUS Failed for Slot B Logical Partitions

```
[2.231888] init: DM_DEV_STATUS failed for system_ext_b: No such device or address
[2.231891] init: Could not update logical partition
[2.231952] init: DM_DEV_STATUS failed for product_b: No such device or address
[2.231954] init: Could not update logical partition
```

**Observation**: `init` attempts to update the `_b` slot logical partitions (`system_ext_b`, `product_b`) but they have no dm-verity device mapper entry. This is **expected** because the device is currently booting slot `_a`. Init continues past this.

---

### 4. ⚠️ Apex SEPolicy Signature Check Warning

```
[2.232039] init: Falling back to standard signature check.
[2.232044] init: Error: Apex SEPolicy failed signature check
[2.232046] init: Loading APEX Sepolicy from /system/etc/selinux/apex/SEPolicy.zip
[2.232051] init: Failed to open package /system/etc/selinux/apex/SEPolicy.zip: No such file or directory
```

**Observation**: APEX SEPolicy signature check fails and the fallback path (`/system/etc/selinux/apex/SEPolicy.zip`) does not exist. Init falls back to loading the standard `/system/etc/selinux/plat_sepolicy.cil` instead. SELinux loads successfully (`SELinux: policy capability open_perms=1`). **Non-fatal.**

---

### 5. 🚨 `vendor/etc/ueventd.rc` — MISSING FROM VENDOR PARTITION

```
[2.346876] ueventd: Unable to read config file '/vendor/etc/ueventd.rc': open() failed: No such file or directory
```

**Observation**: `ueventd` attempts to parse `/vendor/etc/ueventd.rc` and cannot find it. This file defines:
- Custom device node creation rules for ASUS/Qualcomm hardware
- Firmware loading paths (`/vendor/firmware`)
- Device node permissions for `/dev/kgsl-3d0`, `/dev/ion`, `/dev/dma_heap/system`, etc.

**Without this file, ueventd uses only the default AOSP rules** from `/system/etc/ueventd.rc`, which do not include vendor-specific device node rules. This means:
- Firmware loading may use wrong paths
- Vendor device nodes (`/dev/kgsl-3d0`, `/dev/msm_vidc*`) may have wrong permissions
- HAL services that need to open these device nodes may fail with `EACCES` (permission denied)

**Verification needed**: Check if `/vendor/etc/ueventd.rc` exists in the built vendor image.

---

### 6. 🟡 `ipa_fws.mdt` — Continuous Retry Loop

```
[7.715266] ueventd: firmware: attempted /vendor/firmware/ipa_fws.mdt, open failed: No such file or directory
```

**Observation**: IPA (IP Accelerator) firmware is searched via `ueventd` sysfs fallback and cannot be found in `/vendor/firmware`. `ipa_fws.mdt` IS present in the built `vendor.img`, but `ueventd` is not finding it. This is likely because `/vendor/etc/ueventd.rc` is missing and ueventd's firmware search path is incomplete.

---

## 🎯 Priority-Ranked Hypotheses (Evidence-Based)

### Rank 1 — `vendor/etc/ueventd.rc` Missing

**Single Hypothesis**:
> If `ueventd` cannot find `/vendor/etc/ueventd.rc`, it will not create vendor-specific device nodes and will use incorrect firmware search paths. This may prevent `kgsl` (GPU), `ion`, or other HAL-critical device nodes from being accessible, causing HAL services to fail silently when trying to open these nodes.

**Confirmation test**: Verify whether `/vendor/etc/ueventd.rc` exists in the built `vendor.img`.

