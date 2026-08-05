# 🔬 Feasibility & Interoperability Audit: Hybrid OSS CAF Display HALs + Stock ASUS Pixelworks Stack

---

## 1. Executive Summary & Objective

This architectural audit investigates whether the **stock ASUS Pixelworks Iris 6 hardware display co-processor stack** (`vendor.pixelworks.hardware.display.iris-service`, `vendor.pixelworks.hardware.feature.irisfeature-service`, `libpwirisIoctlWrapper.so`) can interoperate directly with the **open-source Qualcomm CAF display stack** (`composer-service`, `allocator-service`, `libsdmcore`, `gralloc4`) on the **ASUS ROG Phone 5S (`rog5s` / `ZS676KS` / `SM8350`)**.

### Primary Conclusion
**YES, a hybrid architecture is technically feasible.** Stock Pixelworks services interact with display hardware via standard **HIDL interfaces** (`vendor.pixelworks.hardware.display@1.0/1.1`) and kernel DRM ioctls (`/dev/dri/card0` via `libdrm.so`). Interoperability does not require modifying proprietary binaries—it requires satisfying specific shared library dependencies (`libqdMetaData.so`, `libdisplaydebug.so`) and VINTF HIDL manifest declarations.

---

## 2. Shared Library & Interface Audit (`readelf -d` & Dynamic Symbols)

### A. `vendor.pixelworks.hardware.display.iris-service`
* **Binary Location**: `/vendor/bin/hw/vendor.pixelworks.hardware.display.iris-service`
* **Registered VINTF Interface**: HIDL `vendor.pixelworks.hardware.display@1.0::IPxlwControl` & `@1.1::IPxlwControl`
* **`DT_NEEDED` Shared Libraries**:
  ```text
  liblog.so
  libutils.so
  libcutils.so
  libqdMetaData.so                     <── [Open-Source: hardware/qcom-caf/sm8350/display/libqdmetadata]
  libhardware.so
  libsdmcore.so                        <── [Open-Source: hardware/qcom-caf/sm8350/display/sdm]
  libhidlbase.so
  libhidltransport.so
  vendor.pixelworks.hardware.display@1.1.so
  libpwirisservice.so
  libc++.so
  ```

---

### B. `vendor.pixelworks.hardware.feature.irisfeature-service`
* **Binary Location**: `/vendor/bin/hw/vendor.pixelworks.hardware.feature.irisfeature-service`
* **Registered VINTF Interface**: HIDL `vendor.pixelworks.hardware.feature@1.0::IIrisFeature`
* **`DT_NEEDED` Shared Libraries**:
  ```text
  liblog.so
  libutils.so
  libcutils.so
  libhardware.so
  libbinder.so
  libhidlbase.so
  libhidltransport.so
  vendor.pixelworks.hardware.display@1.0.so
  vendor.pixelworks.hardware.feature@1.0.so
  libpwirisIoctlWrapper.so             <── [Proprietary Kernel DRM Ioctl Engine]
  libc++.so
  ```

---

### C. `libpwirisIoctlWrapper.so`
* **Library Location**: `/vendor/lib64/libpwirisIoctlWrapper.so`
* **`DT_NEEDED` Shared Libraries**:
  ```text
  libdrm.so                            <── [Kernel DRM Master /dev/dri/card0]
  liblog.so
  libutils.so
  libc++.so
  ```

---

### D. `libsdm-disp-vndapis.so`
* **Library Location**: `/vendor/lib64/libsdm-disp-vndapis.so`
* **`DT_NEEDED` Shared Libraries**:
  ```text
  libdisplaydebug.so                   <── [Open-Source: hardware/qcom-caf/sm8350/display/libdebug]
  libqservice.so
  libbinder.so
  libcutils.so
  libutils.so
  liblog.so
  ```

---

## 3. Hardware Node & Property Mapping

* **`/dev/dri/card0`**: Accessed via `libdrm.so` inside `libpwirisIoctlWrapper.so` to send DRM custom atomic properties (`SDE_DRM_CPROP_...`) directly to `msm_drm` / `sde_kms`.
* **`/sys/devices/system/cpu/cpu0..7/cpufreq/`**: Referenced by `libpwirisservice.so` for Pixelworks high-framerate (144Hz) CPU frequency boost policies.
* **`persist.sys.display.iris.absent`**: Read by `libpwirisservice.so` (set to `0` on ROG 5/5S hardware).
* **`persist.vendor.display.pxlw.dual_frc`**: Read/written by `libpwirisservice.so` for dual-channel Frame Rate Compensation (MEMC).

---

## 4. Minimum Required Adaptation (Zero Source Code Edits)

To establish 100% clean interoperability between open-source CAF Display HALs and stock Pixelworks services:

1. **Build `libqdMetaData.so` & `libdisplaydebug.so`**: Add `libqdMetaData` and `libdisplaydebug` to `PRODUCT_PACKAGES` in `device.mk` (compiles from `hardware/qcom-caf/sm8350/display/libqdmetadata` and `hardware/qcom-caf/sm8350/display/libdebug`).
2. **Include Pixelworks VINTF Manifests**: Include `vendor.pixelworks.hardware.display.iris-service.xml` in `PRODUCT_PACKAGES`.
3. **Enable Gralloc Reserved Size**: Set `SOONG_CONFIG_qtidisplay_gralloc_handle_has_reserved_size := true` in `BoardConfig.mk`.
