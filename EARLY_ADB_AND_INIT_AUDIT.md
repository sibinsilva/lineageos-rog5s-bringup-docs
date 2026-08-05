# 🔬 Three-Way Ramdisk & Early ADB Diagnostic Audit Report

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: August 3, 2026  
**Source Log Audited**: `Pasted text(27).txt` (Lineage Recovery Runtime Log)

---

## 📑 1. Executive Summary

Analysis of `Pasted text(27).txt` (the working Lineage Recovery boot log) against our compiled LineageOS System image reveals **why ADB is unavailable during the system boot hang**:

1. **Recovery Mode ADB Behavior** (`ro.boot.mode=recovery`):
   - In Recovery, `ro.boot.adb.enable=1` and `ro.debuggable=1` trigger `on init` ➔ `setprop sys.usb.config adb`.
   - `adbd` starts immediately at `t = 0.22s` (`init.svc.adbd=running`, PID `463`), binding USB controller `a600000.dwc3` to FunctionFS (`sys.usb.ffs.ready=1`).
2. **System Mode ADB Gating** (`ro.boot.mode=boot`):
   - In System mode, `adbd` is marked `disabled` in `/system/etc/init/adbd.rc`.
   - `init` delays starting `adbd` until `late-init` reads persistent properties from `/data/property/persistent_properties`.
   - If Android userspace hangs during `early-boot` or `boot` (before `late-init`), **`sys.usb.config` is never updated, `adbd` never starts, and ADB remains completely dead**.
3. **Solution — Early-Stage ADB Trigger**:
   - By injecting early ADB properties (`setprop sys.usb.config adb`) into `init.rog5s.rc` during `on init`, `adbd` is forced to start within the **first 1–2 seconds of system boot**.
   - This opens ADB **BEFORE** `SurfaceFlinger`, `Zygote`, or `SystemServer` execute, giving us live `adb logcat` access during the ROG logo hang!

---

## 📊 2. Ramdisk & ADB Gating Comparison Matrix

| Property / Feature | Lineage Recovery Ramdisk | Lineage System Image | Behavior Impact |
| :--- | :--- | :--- | :--- |
| **Boot Mode** | `ro.boot.mode=recovery` | `ro.boot.mode=boot` | System mode defers USB config to late-init |
| **Debuggable** | `ro.debuggable=1` | `ro.debuggable=1` (userdebug) | Both builds support root & ADB |
| **USB Controller** | `ro.boot.usbcontroller=a600000.dwc3` | `ro.boot.usbcontroller=a600000.dwc3` | Qualcomm USB hardware controller matches |
| **ADB Service Trigger** | Immediate in `init.rc` (`t=0.22s`) | Gated by `sys.usb.config=adb` | **System mode waits for late-init** |
| **FunctionFS Ready** | `sys.usb.ffs.ready=1` (`t=0.23s`) | Delayed until `adbd` opens socket | **FunctionFS endpoint never binds** |

---

## ⚡ 3. Implementation: Enabling Early-Stage System ADB

To force `adbd` to launch in the first 1–2 seconds of system boot, update `device/asus/rog5s/init/init.rog5s.rc`:

```text
on init
    # Set Qualcomm USB controller
    setprop sys.usb.controller a600000.dwc3
    # Force USB config to ADB early
    setprop sys.usb.config adb

on post-fs-data
    # Force adbd daemon to start
    start adbd
```

---

## 🎯 4. Benefits of Early-Stage ADB

Once Early-Stage ADB is compiled into the system build:

1. Connect USB cable to PC during boot.
2. As soon as the ASUS ROG logo appears, run on PC:
   ```bash
   adb logcat -v threadtime
   ```
3. `logcat` will stream the **exact live initialization sequence** of all Android services (`servicemanager`, `hwservicemanager`, `composer-service`, `surfaceflinger`, `zygote`), instantly revealing the single halted service!
