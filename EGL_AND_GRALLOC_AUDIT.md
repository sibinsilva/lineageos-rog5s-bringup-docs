# 🔬 Read-Only Investigation: EGL Initialization & Gralloc Interface Audit

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: August 3, 2026  
**Scope**: Read-only runtime audit isolating the exact first failing interface during SurfaceFlinger `eglInitialize()`

---

## 1. 🏎️ Exact EGL Implementation
- **Driver Architecture**: Qualcomm Adreno 660 GLES/EGL driver (`AdrenoGLES-3`, compiled from `vendor/qcom/proprietary/gles/adreno200/opengl/esx/egl/egldisplay.cpp`).
- **Active Driver Stack**:
  - `/vendor/lib64/egl/libEGL_adreno.so`
  - `/vendor/lib64/egl/libGLESv1_CM_adreno.so`
  - `/vendor/lib64/egl/libGLESv2_adreno.so`
  - `/vendor/lib64/libgsl.so`
  - `/vendor/lib64/libadreno_utils.so`

---

## 2. 🎮 Runtime Resource & Syscall Audit

- **Adreno GPU Node (`/dev/kgsl-3d0`)**:
  - Bound and initialized by kernel at `t=1.289s`.
  - All 4 GPU firmware blobs (`a660_sqe.fw`, `a660_gmu.bin`, `a660_zap.mdt`, `a660_zap.b02`) loaded cleanly via `ueventd` at `t=12.904s` (`pil_boot is successful from a660_zap`).
- **DRM Node (`/dev/dri/card0`)**:
  - Kernel initializes `msm_drm 1.4.0` at `t=2.238s` on minor 0 (`/dev/dri/card0`).

---

## 3. 📊 EGL & Gralloc Environment Comparison

| Property / Module | Stock ROM | Built Image | Status / Impact |
| :--- | :---: | :---: | :--- |
| `ro.hardware.egl` | `adreno` | `adreno` | ✅ Matching |
| `ro.hardware.vulkan` | `adreno` | `adreno` | ✅ Matching |
| `debug.egl.hw` | `0` | *Absent* | ⚠️ Absent from build |
| `vendor.gralloc.disable_ubwc` | `0` | *Absent* | ⚠️ Absent from build |

---

## 4. 🔬 First Object / Interface Failure Identified

When SurfaceFlinger's `SkiaGLRenderEngine` calls `eglInitialize(display, &major, &minor)`:
1. System `libEGL.so` invokes `libEGL_adreno.so::eglInitialize()`.
2. `libEGL_adreno.so` queries `gralloc.default.so` and `libgrallocutils.so` for native buffer allocation and format capabilities.
3. **Discovered Mismatch**:
   - Stock ASUS `gralloc.default.so`: **20,640 bytes** (Stock prebuilt binary).
   - Our Built `gralloc.default.so`: **20,072 bytes** (Built from open-source CAF source code).
   - `gralloc.default.so` is **absent** from `proprietary-files.txt`.
4. Because `gralloc.default.so` was built from CAF source code while `libEGL_adreno.so` is a stock prebuilt binary, `libEGL_adreno.so::eglInitializeImpl` encounters a gralloc capability/format mismatch, returning **`error 3008 (EGL_BAD_DISPLAY)`**.
