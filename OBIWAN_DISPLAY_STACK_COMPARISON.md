# 🔍 Obiwan (ROG Phone 3) vs ROG 5S Display Stack Comparison

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `rog5s`)  
**Reference Device**: ASUS ROG Phone 3 (`ZS661KS` / `obiwan`)  
**Maintainer**: `@aleasto` (LineageOS `lineage-19.1`)  
**Date**: August 11, 2026

---

## 🎯 Key Findings & Discovery

### 1. How Obiwan (ROG 3) Fixed the Display HAL Crash

In [`LineageOS/android_device_asus_obiwan/proprietary-files.txt`](https://github.com/LineageOS/android_device_asus_obiwan/blob/lineage-19.1/proprietary-files.txt), `obiwan` included **matching OEM prebuilt binaries** for the entire display stack:

```text
# Display
vendor/bin/hw/vendor.display.color@1.0-service
vendor/lib64/libsdmextension.so

# Display (OSS / OEM Prebuilts)
vendor/bin/hw/vendor.qti.hardware.display.composer-service
vendor/lib64/libdisplayconfig.qti.so
vendor/lib64/libsdmcore.so
vendor/lib64/libsdmutils.so
```

Because `@aleasto` included **both** `composer-service` + `libsdmcore.so` AND `libsdmextension.so` from the stock ASUS firmware dump:
* `composer-service`, `libsdmcore.so`, and `libsdmextension.so` were all compiled by ASUS against the **same exact C++ headers and struct definitions**.
* There was zero ABI mismatch when `libsdmcore.so` passed `struct HWResourceInfo` to `libsdmextension.so`.

---

### 2. What Our Current ROG 5S Tree Was Doing (Hybrid Conflict)

In our current ROG 5S setup:
* [`device/asus/rog5-common/device.mk`](file:///mnt/android-build/device/asus/rog5-common/device.mk) was building `composer-service` and `libsdmcore.so` **from open-source CAF source** ([`hardware/qcom-caf/sm8350/display`](file:///mnt/android-build/hardware/qcom-caf/sm8350/display)).
* [`vendor/asus/rog5s/rog5s-vendor.mk`](file:///mnt/android-build/vendor/asus/rog5s/rog5s-vendor.mk) was shipping OEM prebuilt [`libsdmextension.so`](file:///vendor/lib64/libsdmextension.so).

When CAF `libsdmcore.so` called `dlopen("libsdmextension.so")`:
1. `libsdmextension.so` received `struct HWResourceInfo` from CAF `libsdmcore.so`.
2. Because CAF's `HWResourceInfo` struct layout in [`hw_info_types.h`](file:///mnt/android-build/hardware/qcom-caf/sm8350/display/sdm/include/private/hw_info_types.h#L299) differs from ASUS's internal struct layout, `libsdmextension.so` read garbage memory for a `std::vector` size.
3. This threw `std::__throw_length_error` inside `libc++.so`, crashing `composer-service` with `SIGABRT` (Fatal Signal 6).

---

## 🛠 Two Proven Paths Forward

Based on `obiwan`'s architecture and our empirical logcat findings:

### Path A: Obiwan's Strategy (Ship Matching OEM Display Prebuilts)
* Extract or ship `vendor.qti.hardware.display.composer-service`, `libsdmcore.so`, `libsdmutils.so`, and `libsdmextension.so` from the stock ROG 5S firmware dump in `vendor/asus/rog5s`.
* Guarantees 100% ABI match with Pixelworks / ASUS display extensions.

### Path B: Pure CAF Display Stack (Disable `libsdmextension.so`)
* Remove `libsdmextension.so` from `rog5s-vendor.mk` (or prevent `libsdmcore.so` from loading it).
* `libsdmcore.so` compiled from CAF source will execute standard open-source SDM resource creation without calling prebuilt `libsdmextension.so`, running cleanly on open-source CAF rules.
