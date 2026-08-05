# 🔬 Read-Only Runtime Investigation: SurfaceFlinger EGL Initialization Failure

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: August 3, 2026  
**Scope**: Read-only logcat & dmesg analysis of the new EGL startup blocker (No code modifications)

---

## 1. 📜 Complete EGL Startup Sequence (Logcat Trace)

```text
07-30 18:27:15.942  1069  1119 D libEGL  : loaded /vendor/lib64/egl/libEGL_adreno.so
07-30 18:27:16.002  1069  1119 D libEGL  : loaded /vendor/lib64/egl/libGLESv1_CM_adreno.so
07-30 18:27:16.005  1069  1119 D libEGL  : loaded /vendor/lib64/egl/libGLESv2_adreno.so
07-30 18:27:16.038  1069  1119 E libEGL  : eglInitializeImpl:281 error 3008 (EGL_BAD_DISPLAY)
07-30 18:27:16.038  1069  1119 F RenderEngine: failed to initialize EGL
07-30 18:27:16.038  1069  1119 F libc    : Fatal signal 6 (SIGABRT), code -1 (SI_QUEUE) in tid 1119 (surfaceflinger), pid 1069 (surfaceflinger)
```

---

## 2. 🎮 GPU Device Availability (`/dev/kgsl-3d0` & Kernel GMU)

- **Device Registration**: Kernel registers `3d00000.qcom,kgsl-3d0` at `t=1.289s`.
- **Firmware Loading Sequence**:
  - `a660_sqe.fw`: Loaded at `t=12.822s`.
  - `a660_gmu.bin`: Loaded at `t=12.824s`.
  - `a660_zap.mdt` / `a660_zap.b02`: Loaded at `t=12.903s`.
  - **Result**: `subsys_powerup(): pil_boot is successful from a660_zap` at `t=12.904s`.
- **SELinux Status**: **0 SELinux denials** detected for `/dev/kgsl-3d0`, GPU nodes, or SurfaceFlinger.

---

## 3. 📦 EGL Implementation Selection

All 3 Qualcomm Adreno EGL vendor libraries were successfully located and loaded by `libEGL.so`:
- ✅ `/vendor/lib64/egl/libEGL_adreno.so` (Loaded at `t=18:27:15.942`)
- ✅ `/vendor/lib64/egl/libGLESv1_CM_adreno.so` (Loaded at `t=18:27:16.002`)
- ✅ `/vendor/lib64/egl/libGLESv2_adreno.so` (Loaded at `t=18:27:16.005`)

---

## 4. 📊 Property Comparison (Stock vs Build)

| Property | Stock Value | Built Value | Status |
| :--- | :--- | :--- | :--- |
| `ro.hardware.egl` | `adreno` | `adreno` | ✅ Matching |
| `ro.hardware.vulkan` | `adreno` | `adreno` | ✅ Matching |
| `ro.surface_flinger.max_frame_buffer_acquired_buffers` | `3` | `3` | ✅ Matching |
| `ro.surface_flinger.max_virtual_display_dimension` | `4096` | `4096` | ✅ Matching |
| `debug.egl.hw` | `0` | *Absent* | ⚠️ Absent from build |
| `vendor.gralloc.disable_ubwc` | `0` | *Absent* | ⚠️ Absent from build |

---

## 5. 🎯 First Concrete Failure Site Identified

- **First Failing API Call**: `eglInitializeImpl:281 error 3008 (EGL_BAD_DISPLAY)` inside `/vendor/lib64/egl/libEGL_adreno.so`.
- **Root Cause Correlation**:  
  Logcat line 5870 shows:
  ```text
  vndksupport: Could not load /vendor/lib64/hw/camera.qcom.so: library "vendor.qti.hardware.display.allocator@3.0.so" not found
  ```
  When `eglInitialize()` is invoked, Adreno's `libEGL_adreno.so` queries the gralloc allocator/mapper HIDL service (`vendor.qti.hardware.display.allocator@3.0.so` / `@4.0.so`). Because `vendor.qti.hardware.display.allocator@3.0.so` is missing from `/vendor/lib64/`, EGL initialization fails and returns `EGL_BAD_DISPLAY`.
