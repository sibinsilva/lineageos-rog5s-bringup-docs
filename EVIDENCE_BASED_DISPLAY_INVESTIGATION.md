# 🔬 Evidence-Based Investigation: `composer-service` Startup Crash

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: August 3, 2026  
**Scope**: 5-point evidence-driven audit requested by user without code modifications

---

## 1. 🔍 Live Logcat Investigation

**Process**: `/vendor/bin/hw/vendor.qti.hardware.display.composer-service` (PID 12601)  
**Signal**: `SIGABRT` (signal 6)  
**Abort Message**: `terminating with uncaught exception of type std::length_error: vector`

### Exact Stack Trace (tombstone / logcat)
```text
#00 pc 00000000000531e4  /apex/com.android.runtime/lib64/bionic/libc.so (abort+164)
#01 pc 0000000000049128  /apex/com.android.vndk.v33/lib64/libc++.so (abort_message+248)
#02 pc 0000000000049300  /apex/com.android.vndk.v33/lib64/libc++.so (demangling_terminate_handler()+208)
#03 pc 0000000000049f5c  /apex/com.android.vndk.v33/lib64/libc++.so (std::__terminate)
#04 pc 000000000004955c  /apex/com.android.vndk.v33/lib64/libc++.so (__cxxabiv1::failed_throw)
#05 pc 00000000000494b4  /apex/com.android.vndk.v33/lib64/libc++.so (__cxa_throw+116)
#06 pc 000000000009a188  /apex/com.android.vndk.v33/lib64/libc++.so (std::__1::__throw_length_error)
#07 pc 00000000000a5230  /apex/com.android.vndk.v33/lib64/libc++.so (std::__1::__vector_base_common<true>::__throw_length_error)
#08 pc 000000000006eb3c  /vendor/lib64/libsdmextension.so (sdm::HWResourceInfo::HWResourceInfo(sdm::HWResourceInfo const&)+1232)
#09 pc 00000000000943c0  /vendor/lib64/libsdmextension.so (sdm::CreateResource(sdm::HWResourceInfo const&, sdm::BufferAllocator*, sdm::ResourceInterface**)+60)
#10 pc 000000000006268c  /vendor/lib64/libsdmextension.so (sdm::ExtensionImpl::CreateResourceExtn(sdm::HWResourceInfo const&, sdm::BufferAllocator*, sdm::ResourceInterface**)+380)
#11 pc 000000000004d3bc  /vendor/lib64/libsdmcore.so (sdm::CompManager::Init(sdm::HWResourceInfo const&, sdm::ExtensionInterface*, sdm::BufferAllocator*, sdm::SocketHandler*)+76)
#12 pc 000000000002fdc4  /vendor/lib64/libsdmcore.so (sdm::CoreImpl::Init()+308)
#13 pc 000000000002f1a0  /vendor/lib64/libsdmcore.so (sdm::CoreInterface::CreateCore)
#14 pc 0000000000064b34  /vendor/bin/hw/vendor.qti.hardware.display.composer-service (sdm::HWCSession::InitSupportedDisplaySlots()+260)
#15 pc 00000000000648e4  /vendor/bin/hw/vendor.qti.hardware.display.composer-service (sdm::HWCSession::Init()+1140)
```

**Key Observation**: The crash happens in frame **#08**: `sdm::HWResourceInfo::HWResourceInfo(sdm::HWResourceInfo const&)` — which is the **copy constructor** of the `HWResourceInfo` C++ struct.

---

## 2. 📊 `vendor.display.*` Property Audit (Stock vs Built Image)

### Complete Inventory of `vendor.display.*` Properties

| Property Name | Stock Value | Built Image Value | Status |
| :--- | :--- | :--- | :--- |
| `vendor.display.comp_mask` | `0` | `0` | ✅ Present & Matching |
| `vendor.display.disable_excl_rect` | `0` | `0` | ✅ Present & Matching |
| `vendor.display.disable_excl_rect_partial_fb` | `1` | `1` | ✅ Present & Matching |
| `vendor.display.disable_hw_recovery_dump` | `1` | `1` | ✅ Present & Matching |
| `vendor.display.disable_offline_rotator` | `1` | `1` | ✅ Present & Matching |
| `vendor.display.enable_async_powermode` | `0` | `0` | ✅ Present & Matching |
| `vendor.display.enable_optimize_refresh` | `1` | `1` | ✅ Present & Matching |
| `vendor.display.disable_scaler` | `0` | *Absent* | ⚠️ Absent from build |
| `vendor.display.enable_early_wakeup` | `0` (or `1`) | *Absent* | ⚠️ Absent from build |
| `vendor.display.enable_posted_start_dyn` | `2` | *Absent* | ⚠️ Absent from build |
| `vendor.display.use_smooth_motion` | `1` | *Absent* | ⚠️ Absent from build |
| `vendor.display.disable_rounded_corner` | `0` | *Absent* | ⚠️ Absent from build |

---

## 3. 🔬 Code & ABI Analysis: Root Cause of `std::length_error`

### Build Origin Comparison of Display Stack Components

| Component | Build Origin | Source Path |
| :--- | :--- | :--- |
| `vendor.qti.hardware.display.composer-service` | **Built from source** | `hardware/qcom-caf/sm8350/display/composer/` |
| `libsdmcore.so` | **Built from source** | `hardware/qcom-caf/sm8350/display/sdm/libs/core/` |
| `libsdmextension.so` | **Prebuilt Proprietary Blob** | `vendor/asus/rog5s/proprietary/vendor/lib64/libsdmextension.so` (`proprietary-files.txt:738`) |

### Structural Cause

1. `libsdmcore.so` (built from open-source CAF tree) calls `extension_intf->CreateResourceExtn(hw_res_info, ...)`.
2. `libsdmextension.so` is a **prebuilt closed-source vendor library** from the stock ASUS ROM.
3. `CreateResourceExtn` passes `const HWResourceInfo &hw_resource_info` into `sdm::CreateResource()`.
4. In `sdm::CreateResource()`, `HWResourceInfo` is copied via its copy constructor (`HWResourceInfo::HWResourceInfo(const HWResourceInfo&)`).
5. The `HWResourceInfo` struct defined in `hardware/qcom-caf/sm8350/display/sdm/include/private/hw_info_types.h` has a **different layout / struct size** than the `HWResourceInfo` struct compiled into ASUS stock `libsdmextension.so`.
6. When `libsdmextension.so` accesses vector members (`hw_pipes`, `tap_points`, `supported_formats_map`) inside `HWResourceInfo`, it reads at an offset that does not match the memory layout prepared by `libsdmcore.so`.
7. This causes `std::vector` copy constructor inside `libsdmextension.so` to read garbage as the vector `size`/`capacity`, throwing **`std::length_error: vector`**.

---

## 🎯 Findings & Recommendations

1. **Properties Analysis**: The 7 core `vendor.display.*` properties (`comp_mask`, `disable_offline_rotator`, `disable_excl_rect`, etc.) are **already present** in our built `vendor/build.prop`. The 5 missing properties (`disable_scaler`, `enable_posted_start_dyn`, `use_smooth_motion`, `enable_early_wakeup`, `disable_rounded_corner`) are optional features and do not alter struct sizes.

2. **Isolated Root Cause**: The crash is an **ABI mismatch across the `HWResourceInfo` struct boundary** between `libsdmcore.so` (built from CAF source) and `libsdmextension.so` (prebuilt stock blob).

3. **Targeted Options**:
   - **Option A (Prebuilt Display Core)**: Include stock ASUS `libsdmcore.so` in `proprietary-files.txt` so `libsdmcore.so` and `libsdmextension.so` share the exact same prebuilt ABI.
   - **Option B (Prebuilt Composer Service)**: Include stock ASUS `vendor.qti.hardware.display.composer-service` in `proprietary-files.txt` so the entire display HAL binary stack comes from stock ASUS binaries.
