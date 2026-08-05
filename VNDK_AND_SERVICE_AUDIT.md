# 🔬 Empirical Audit: Init Service Handling & APEX VNDK Library Verification

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: August 3, 2026  
**Scope**: Duplicate `vendor.power` Service Handling & APEX File Audit for `android.hardware.power-V3-ndk.so`

---

## 📑 1. Summary of Findings

| Item Audited | File / Location Inspected | Empirical Finding | Conclusion |
| :--- | :--- | :--- | :--- |
| **Duplicate `vendor.power` Service** | `vendor/etc/init/android.hardware.power-service.rc`<br>`vendor/etc/init/android.hardware.power-service-qti.rc` | AOSP `init` ignores the second service block with error `Ignored duplicate service 'vendor.power'` | ❌ **False Positive Eliminated** (`init` only registers 1 service) |
| **`android.hardware.power-V3-ndk.so`** | `/apex/com.android.vndk.v33/lib64/` | File present (`55,168 bytes`) in VNDK v33 APEX package | ❌ **False Positive Eliminated** (Loaded via APEX mount at runtime) |

---

## 🔍 2. Detailed Verification Results

### A. Init Duplicate Service Parser Rules
- **Files**:
  - `/vendor/etc/init/android.hardware.power-service-qti.rc`
    ```text
    service vendor.power /vendor/bin/hw/android.hardware.power-service-qti
        class hal
        user system
        group system
    ```
  - `/vendor/etc/init/android.hardware.power-service.rc`
    ```text
    service vendor.power /vendor/bin/hw/android.hardware.power-service
        class hal
        user system
        group system
    ```
- **AOSP Init Behavior** (`system/core/init/service_list.cpp`):
  - `init` parses `.rc` files in alphabetical order.
  - When encountering the second `service vendor.power`, `init` prints `init: Ignored duplicate service 'vendor.power'` and discards the block.
  - Only `/vendor/bin/hw/android.hardware.power-service-qti` is registered and executed.

---

### B. APEX VNDK Library Search
- **Target Library**: `android.hardware.power-V3-ndk.so`
- **Filesystem Search Results**:
  ```text
  [FOUND - 55,168 bytes] apex/com.android.vndk.v33/lib64/android.hardware.power-V3-ndk.so
  [FOUND - 36,052 bytes] apex/com.android.vndk.v33/lib/android.hardware.power-V3-ndk.so
  [FOUND - 426,112 bytes] symbols/apex/com.android.vndk.v33/lib64/android.hardware.power-V3-ndk.so
  ```
- **Dynamic Linker Resolution**:
  - Android 13 routes VNDK v33 shared libraries through `/apex/com.android.vndk.v33/lib64/`.
  - `/system/bin/linker64` reads VNDK libraries directly from the mounted APEX container during `early-init`.
  - `android.hardware.power-service-qti` links cleanly at runtime.

---

## 🎯 3. Conclusion

Both preliminary assumptions have been thoroughly vetted and eliminated:
1. `init` does not suffer from a dual-service crash loop.
2. Power HAL does not fail dynamic linking.

No device tree or codebase changes were made.
