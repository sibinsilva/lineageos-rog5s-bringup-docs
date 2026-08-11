# 🔬 Deep Investigation: Pure CAF OSS Display HAL Extension Loading Mechanics

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `rog5s` / SM8350 `lahaina`)  
**Date**: August 11, 2026  
**Status**: INVESTIGATION COMPLETE (Read-Only Analysis)

---

## 🔍 Executive Findings

1. **Optional Nature of `libsdmextension.so` in QTI CAF Source**:
   In [`hardware/qcom-caf/sm8350/display/sdm/libs/core/core_impl.cpp`](file:///mnt/android-build/hardware/qcom-caf/sm8350/display/sdm/libs/core/core_impl.cpp#L53-L76), `libsdmcore.so` attempts to load `libsdmextension.so` dynamically using `DynLib::Open("libsdmextension.so")`.

2. **Graceful Fallback Path**:
   If `libsdmextension.so` cannot be opened or is omitted from the vendor filesystem:
   ```cpp
   if (extension_lib_.Open(EXTENSION_LIBRARY_NAME)) {
       // ... initialize extension interface ...
   } else {
       DLOGW("Unable to load = %s, error = %s", EXTENSION_LIBRARY_NAME, extension_lib_.Error());
   }
   error = HWInfoInterface::Create(&hw_info_intf_);
   ```
   * **Key Result**: `CoreImpl::Init()` logs a standard warning (`DLOGW`) and **continues execution cleanly**. It does NOT return an error, and it does NOT throw an exception.

3. **Root Cause of Crash with OEM `libsdmextension.so`**:
   When OEM `libsdmextension.so` is present on the vendor partition:
   * CAF `libsdmcore.so` successfully opens `libsdmextension.so` and calls `create_extension_intf_()`.
   * During initialization, `libsdmextension.so` calls `sdm::HWResourceInfo::HWResourceInfo(const sdm::HWResourceInfo&)` to copy hardware resource specifications.
   * Due to line 335 of CAF header [`hw_info_types.h`](file:///mnt/android-build/hardware/qcom-caf/sm8350/display/sdm/include/private/hw_info_types.h#L335) (`std::vector<CwbTapPoint> tap_points`), CAF `HWResourceInfo` is 24 bytes larger than OEM `HWResourceInfo`.
   * Offset misalignment causes `libsdmextension.so` copy constructor to read scalar fields as vector pointers, triggering `std::__throw_length_error` inside `libc++.so` and crashing `composer-service` with **Fatal signal 6 (`SIGABRT`)**.

4. **Pure CAF OSS Display Solution**:
   Omitting `libsdmextension.so` allows CAF-built `libsdmcore.so` and `vendor.qti.hardware.display.composer-service` to run native QTI DRM/KMS display hardware initialization without invoking the incompatible OEM extension library.
