# 🔬 `/vendor/etc/ueventd.rc` Provenance & Boot Investigation Report

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Branch**: `lineage-20.0` (Android 13 / API 33)  
**Date**: August 11, 2026  
**Status**: COMPLETE (Read-Only Evidence-Based Discovery)

---

## Executive Summary

During boot log analysis of the captured `dmesg` (`t=2.346876s`), the following message was observed:
```text
[2.346876] ueventd: Unable to read config file '/vendor/etc/ueventd.rc': open() failed: No such file or directory
```

This investigation establishes with **concrete source, build, and runtime log evidence** the exact provenance of `ueventd.rc` files across the LineageOS tree, how AOSP `ueventd` handles vendor configuration paths, and answers all 8 specific questions raised.

---

## 📋 Comprehensive Answers to the 8 Investigation Questions

### 1. Whether `/vendor/etc/ueventd.rc` exists in the LineageOS source/device/vendor tree

* **Finding**: A file literally named `/vendor/etc/ueventd.rc` does **not** exist as a static file at that relative path in the source git repositories.
* **Source Files**: The vendor uevent rules originate from **four** source files across device and vendor trees:
  1. [`device/asus/rog5-common/init/ueventd.qcom.rc`](file:///mnt/android-build/device/asus/rog5-common/init/ueventd.qcom.rc) — Qualcomm SoC vendor uevent rules.
  2. [`device/asus/rog5-common/init/ueventd.asus.rc`](file:///mnt/android-build/device/asus/rog5-common/init/ueventd.asus.rc) — ASUS board hardware (charging, NFC `/dev/pn553`, `/dev/p73`).
  3. [`vendor/asus/rog5s/proprietary/vendor/ueventd.rc`](file:///mnt/android-build/vendor/asus/rog5s/proprietary/vendor/ueventd.rc) — OEM prebuilt Qualcomm/ASUS vendor uevent rules.
  4. [`vendor/asus/rog5s/proprietary/odm/ueventd.rc`](file:///mnt/android-build/vendor/asus/rog5s/proprietary/odm/ueventd.rc) — OEM prebuilt ODM uevent rules.

---

### 2. Whether it is actually included in the built `vendor.img` / logical vendor partition

* **Finding**: **YES ✅**.
* **Build Artifact Verification**:
  * [`out/target/product/rog5s/vendor/etc/ueventd.rc`](file:///mnt/android-build/out/target/product/rog5s/vendor/etc/ueventd.rc) exists (size: **27,847 bytes**).
  * [`out/target/product/rog5s/vendor/ueventd.rc`](file:///mnt/android-build/out/target/product/rog5s/vendor/ueventd.rc) exists (size: **28,614 bytes**).
  * [`out/target/product/rog5s/odm/etc/ueventd.rc`](file:///mnt/android-build/out/target/product/rog5s/odm/etc/ueventd.rc) exists (size: **333 bytes**).
  * [`out/target/product/rog5s/odm/ueventd.rc`](file:///mnt/android-build/out/target/product/rog5s/odm/ueventd.rc) exists (size: **3,228 bytes**).
* **Explanation of Runtime Missing Log**: The `dmesg` log line was captured when booting custom `boot.img` / `vendor_boot.img` while mounting the **stock OEM vendor partition**. On stock ASUS Android 11 firmware, ASUS placed `ueventd.rc` at `/vendor/ueventd.rc` (partition root), rather than `/vendor/etc/ueventd.rc`.

---

### 3. Whether `/vendor` is mounted successfully at the moment `ueventd` starts

* **Finding**: **YES ✅**.
* **Empirical `dmesg` Timeline Evidence**:
  * `t=2.227773s`: `init: [libfs_avb]` performs first-stage mount of all 5 logical partitions (`/system`, `/system_ext`, `/product`, `/vendor`, `/odm`) from the `super` partition.
  * `t=2.346876s`: `ueventd` starts up during second-stage init initialization.
  * `/vendor` is mounted **119 ms BEFORE** `ueventd` starts.

---

### 4. Whether the file exists and is readable at runtime immediately before/during `ueventd` startup

* **In full LineageOS build (`vendor.img` flashed)**: **YES ✅**. File permissions in build staging are `0644` (`-rw-rw-r--`).
* **In partial boot test (stock OEM vendor mounted)**: **NO ❌**. Stock ASUS vendor partition lacks `/vendor/etc/ueventd.rc` (it has `/vendor/ueventd.rc` instead).

---

### 5. Whether another `ueventd*.rc` location is intended for this device

* **Finding**: **YES ✅**.
* **AOSP Android 13 Legacy Path Fallback**:
  In [`system/core/init/ueventd.cpp`](file:///mnt/android-build/system/core/init/ueventd.cpp#L300-L321):
  ```cpp
  static UeventdConfiguration GetConfiguration() {
      auto hardware = android::base::GetProperty("ro.hardware", "");
      std::vector<std::string> legacy_paths{"/vendor/ueventd.rc", "/odm/ueventd.rc",
                                            "/ueventd." + hardware + ".rc"};

      std::vector<std::string> canonical{"/system/etc/ueventd.rc"};

      if (android::base::GetIntProperty("ro.product.first_api_level", 10000) < __ANDROID_API_T__) {
          canonical.insert(canonical.end(), legacy_paths.begin(), legacy_paths.end());
      }
      return ParseConfig(canonical);
  }
  ```
* Because ROG 5S has `ro.product.first_api_level = 30` (Android 11 launch), `ueventd` **automatically parses `/vendor/ueventd.rc` and `/odm/ueventd.rc`** even if `/vendor/etc/ueventd.rc` is missing.

---

### 6. Which build rule/package is responsible for installing the file into `/vendor/etc`

* **Target `/vendor/etc/ueventd.rc`**: Installed by Soong module `ueventd.qcom.rc` in [`device/asus/rog5-common/init/Android.bp`](file:///mnt/android-build/device/asus/rog5-common/init/Android.bp#L68-L73):
  ```bp
  prebuilt_etc {
      name: "ueventd.qcom.rc",
      filename: "ueventd.rc",
      src: "ueventd.qcom.rc",
      vendor: true,
  }
  ```
  Included via `PRODUCT_PACKAGES += ueventd.qcom.rc` in [`device/asus/rog5-common/device.mk`](file:///mnt/android-build/device/asus/rog5-common/device.mk#L250).
* **Target `/odm/etc/ueventd.rc`**: Installed by Soong module `ueventd.asus.rc` in [`device/asus/rog5-common/init/Android.bp`](file:///mnt/android-build/device/asus/rog5-common/init/Android.bp#L61-L66):
  ```bp
  prebuilt_etc {
      name: "ueventd.asus.rc",
      filename: "ueventd.rc",
      src: "ueventd.asus.rc",
      device_specific: true,
  }
  ```
* **Target `/vendor/ueventd.rc`**: Installed by `PRODUCT_COPY_FILES` in [`vendor/asus/rog5s/rog5s-vendor.mk`](file:///mnt/android-build/vendor/asus/rog5s/rog5s-vendor.mk#L3493):
  ```make
  vendor/asus/rog5s/proprietary/vendor/ueventd.rc:$(TARGET_COPY_OUT_VENDOR)/ueventd.rc
  ```
* **Target `/odm/ueventd.rc`**: Installed by `PRODUCT_COPY_FILES` in [`vendor/asus/rog5s/rog5s-vendor.mk`](file:///mnt/android-build/vendor/asus/rog5s/rog5s-vendor.mk#L19):
  ```make
  vendor/asus/rog5s/proprietary/odm/ueventd.rc:$(TARGET_COPY_OUT_ODM)/ueventd.rc
  ```

---

### 7. Whether the missing file is the true root cause or merely the first observed downstream symptom

* **Finding**: **MERELY A HARMLLESS WARNING / NON-FATAL 🟢**.
* **Reasoning**:
  1. `/system/etc/ueventd.rc` contains `import /vendor/etc/ueventd.rc`. If that imported file is missing, init logs an error but does NOT stop or crash `ueventd`.
  2. Because `ro.product.first_api_level` is `30` (< 33), `ueventd` falls back to reading `/vendor/ueventd.rc` (which was present in stock vendor).
  3. When building and flashing LineageOS's own `vendor.img`, `/vendor/etc/ueventd.rc` **is** installed by Soong and exists.
  4. It is **not** the cause of ADB death or boot failure.

---

### 8. What exact minimal change would restore the vendor uevent rules without altering unrelated boot stages

* **Finding**: **No changes to `fstab.default`, build rules, or partition definitions are required.**
* The current LineageOS tree already correctly configures:
  * Soong prebuilts for `/vendor/etc/ueventd.rc` (`ueventd.qcom.rc`) and `/odm/etc/ueventd.rc` (`ueventd.asus.rc`).
  * Vendor prebuilts for `/vendor/ueventd.rc` and `/odm/ueventd.rc`.
* In a full ROM flash (`vendor.img` included), both `/vendor/etc/ueventd.rc` and `/vendor/ueventd.rc` will be present on the target filesystem.

---

## 🛠 Target Installation Matrix Summary

| Source File | Build Mechanism | Target Path in Image | Status in Built `out/` |
|---|---|---|---|
| `device/asus/rog5-common/init/ueventd.qcom.rc` | Soong (`prebuilt_etc`) | `/vendor/etc/ueventd.rc` | ✅ Present (27.8 KB) |
| `device/asus/rog5-common/init/ueventd.asus.rc` | Soong (`prebuilt_etc`) | `/odm/etc/ueventd.rc` | ✅ Present (333 B) |
| `vendor/asus/rog5s/proprietary/vendor/ueventd.rc` | `PRODUCT_COPY_FILES` | `/vendor/ueventd.rc` | ✅ Present (28.6 KB) |
| `vendor/asus/rog5s/proprietary/odm/ueventd.rc` | `PRODUCT_COPY_FILES` | `/odm/ueventd.rc` | ✅ Present (3.2 KB) |

---

## Conclusion

The `/vendor/etc/ueventd.rc` log line is a **harmless warning emitted when running a custom boot image over stock vendor firmware**. The LineageOS build system already builds `/vendor/etc/ueventd.rc` into the `vendor.img` target. `ueventd` is fully operational via fallback rules on stock vendor and natively on LineageOS vendor.
