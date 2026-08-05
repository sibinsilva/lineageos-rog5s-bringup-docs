# 🔬 Comprehensive Audit: Display Subsystem Evolution Across All `sake` Branches

---

## Executive Summary

An exhaustive historical and cross-branch audit was conducted on the official LineageOS repository for **ASUS Zenfone 8 (`sake` / `SM8350`)** across all branches (`lineage-18.1` through `lineage-24.0`). 

As `sake` shares the identical Snapdragon 888 platform (`SM8350` / `lahaina`) and ASUS proprietary display stack conventions with the **ROG Phone 5S (`rog5s` / `ZS676KS`)**, the findings provide the definitive reference implementation for display bring-up, Gralloc alignment, and HAL configuration.

---

## 📑 Key Display Commits & Solutions Identified

### 1. Standardization via Upstream CAF Display Makefiles
* **Commit**: [`fef78f6`](https://github.com/LineageOS/android_device_asus_sake/commit/fef78f6) (`sake: Pick up display HAL makefiles.`)
* **Mechanism**: Rather than manually listing individual display HAL packages in `device.mk`, `sake` inherits the standard Qualcomm CAF display build rules:
  - **`BoardConfig.mk`**:
    ```make
    include hardware/qcom-caf/sm8350/display/config/display-board.mk
    ```
  - **`device.mk`**:
    ```make
    $(call inherit-product, hardware/qcom-caf/sm8350/display/config/display-product.mk)
    $(call inherit-product, vendor/qcom/opensource/commonsys-intf/display/config/display-interfaces-product.mk)
    $(call inherit-product, vendor/qcom/opensource/commonsys-intf/display/config/display-product-system.mk)
    ```
* **Impact**: Ensures 100% of required display HALs, VINTF fragments, and libraries (`composer-service`, `allocator-service`, `mapper@4.0-impl-qti-display`) are inherited consistently with correct Soong namespaces.

---

### 2. Explicit Inclusion of Display Boot Scripts
* **Commit**: [`4e1ebc0`](https://github.com/LineageOS/android_device_asus_sake/commit/4e1ebc0) (`sake: Build init.qti.display_boot scripts`)
* **Mechanism**: Explicitly adds display boot scripts to `PRODUCT_PACKAGES` in `device.mk`:
  ```make
  PRODUCT_PACKAGES += \
      init.qti.display_boot.rc \
      init.qti.display_boot.sh
  ```
* **Impact**: Guarantees `/vendor/bin/init.qti.display_boot.sh` executes under `on post-fs-data`, setting `vendor.display.target.version=1` and initializing `enable_posted_start_dyn` before `composer-service` starts.

---

### 3. Gralloc Reserved Size Handle Alignment
* **Commits**: 
  - [`93c82ab`](https://github.com/LineageOS/android_device_asus_sake/commit/93c82ab) (`sake: Define TARGET_GRALLOC_HANDLE_HAS_RESERVED_SIZE`)
  - [`c45496f`](https://github.com/LineageOS/android_device_asus_sake/commit/c45496f) (`sake: Migrate gralloc_handle_has_reserved_size to soong_config_set`)
* **Mechanism**: Sets `gralloc_handle_has_reserved_size` in `BoardConfig.mk`:
  ```make
  SOONG_CONFIG_NAMESPACES += qtidisplay
  SOONG_CONFIG_qtidisplay += gralloc_handle_has_reserved_size
  SOONG_CONFIG_qtidisplay_gralloc_handle_has_reserved_size := true
  ```
* **Impact**: Matches Qualcomm's kernel ION/DMA-BUF buffer handle structure. Prevents memory offset corruption when passing graphic buffers between `Gralloc 4.0` and kernel DRM drivers.

---

### 4. Prevention of NDK AIDL Symbol Collisions
* **Commit**: [`b5a22af`](https://github.com/LineageOS/android_device_asus_sake/commit/b5a22af) (`sake: Do not build android.hardware.graphics.common-V1-ndk_platform.vendor`)
* **Mechanism**: Removes `android.hardware.graphics.common-V1-ndk_platform.vendor` from `PRODUCT_PACKAGES` in `device.mk`.
* **Impact**: Prevents linker symbol collision between deprecated `V1-ndk_platform` vendor stubs and Android 13 framework `android.hardware.graphics.common-V3-ndk`.

---

### 5. Proprietary Stock Blob Integration (`libdisplayconfig.qti`)
* **Commit**: [`eee5b25`](https://github.com/LineageOS/android_device_asus_sake/commit/eee5b25) (`sake: Take vendor libdisplayconfig.qti from stock.`)
* **Mechanism**: Includes `vendor/lib64/libdisplayconfig.qti.so` directly from stock ASUS firmware in `proprietary-files.txt`.
* **Impact**: Resolves vendor-specific display mode configuration calls used by ASUS system services.

---

## 📊 Comparison Matrix: `sake` vs Current `rog5s` Tree

| Feature / Fix | LineageOS `sake` | Current `rog5s` Tree | Action Item for `rog5s` |
| :--- | :---: | :---: | :--- |
| **CAF Display Inheritance** | Uses `display-product.mk` | Manual package list | Adopt `display-product.mk` inheritance |
| **Display Boot Scripts** | Explicitly in `PRODUCT_PACKAGES` | Implicit | Add `init.qti.display_boot.rc`/`sh` |
| **Gralloc Reserved Size** | Set via `soong_config_set` | Missing | Add `gralloc_handle_has_reserved_size := true` |
| **Graphics Common NDK** | Removed | Present | Remove `android.hardware.graphics.common-V1-ndk_platform.vendor` |
| **Stock Display Config** | Stock `libdisplayconfig.qti.so` | Open-source stub | Ensure stock `libdisplayconfig.qti.so` is pulled |

---

## 💡 Key Takeaways for ROG Phone 5S Bring-Up

1. **Gralloc Handle Alignment**: `SOONG_CONFIG_qtidisplay_gralloc_handle_has_reserved_size := true` is essential on SM8350 to prevent buffer allocation crashes in `allocator-service`.
2. **Clean Display Inheritance**: Replacing ad-hoc display package lists in `device.mk` with `hardware/qcom-caf/sm8350/display/config/display-product.mk` ensures 100% of required VINTF XML fragments and HAL services are pulled automatically.
3. **NDK Stubs Cleanup**: Removing `android.hardware.graphics.common-V1-ndk_platform.vendor` eliminates potential linker crashes during `SurfaceFlinger` startup.
