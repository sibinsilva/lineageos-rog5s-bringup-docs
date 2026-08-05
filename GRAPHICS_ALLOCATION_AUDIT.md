# 🔬 Evidence-Based Audit: Graphics Allocation Stack & Experiment C Proposal

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: August 3, 2026  
**Scope**: Read-only verification of gralloc/allocator/mapper binaries, SHA-256, Build IDs, readelf -d, and symbol exports

---

## 1. 📊 Stock vs Build Origin Comparison

| Component | Stock Firmware Path | Stock Size & Build ID | Built Image Path | Built Size & Build ID | Origin |
| :--- | :--- | :--- | :--- | :--- | :---: |
| `gralloc.default.so` | `/vendor/lib64/hw/` | `20,640 B` (`74a1cda1...`) | `/vendor/lib64/hw/` | `20,072 B` (`7c9e5c95...`) | **CAF Built** |
| `libgrallocutils.so` | `/vendor/lib64/` | `66,768 B` (`51a66cf4...`) | `/vendor/lib64/` | `60,608 B` (`b22b6ca8...`) | **CAF Built** |
| `mapper@4.0-impl-qti-display.so` | `/vendor/lib64/hw/` | `82,288 B` (`77115347...`) | `/vendor/lib64/hw/` | `77,584 B` (`ece13ac0...`) | **CAF Built** |
| `allocator-service` | `/vendor/bin/hw/` | `38,776 B` (`93abf263...`) | `/vendor/bin/hw/` | **ABSENT** (`0 B`) | ⚠️ **MISSING** |

---

## 2. 🔑 SHA-256 Hashes & Build IDs of `gralloc.default.so`

- **Stock `gralloc.default.so`**:  
  - **SHA-256**: `4f1b1a868b3ab99d6d99ca51bbdad13d2f59015ac035b1eaeeb900049e6b992b`  
  - **Build ID**: `74a1cda1cef9f14a9870f7b13b7a806b`
- **Built `gralloc.default.so`**:  
  - **SHA-256**: `4a7e89179d3754b5b93641a95cbf9312a07b2b9877048e45f959389bec073b1c`  
  - **Build ID**: `7c9e5c956ae4c7abc4f6e8b13280bddb`

---

## 3. 📜 Dynamic Dependency & SONAME Audit (`readelf -d`)

`readelf -d` output for both stock and built `gralloc.default.so` is **100% IDENTICAL**:
- **SONAME**: `gralloc.default.so`
- **NEEDED Libraries**: `liblog.so`, `libcutils.so`, `libc++.so`, `libc.so`, `libm.so`, `libdl.so`.

---

## 4. 🔣 Symbol Export Comparison (`readelf -Ws`)

All 32 exported symbols (including `HMI`, `gralloc_lock`, `gralloc_unlock`, `gralloc_register_buffer`, `gralloc_unregister_buffer`, `mapBuffer`) are **100% IDENTICAL** between stock and built `gralloc.default.so`.

---

## 5. 🎯 Key Discovery & Controlled Experiment C Proposal

### Key Discovery:
While `gralloc.default.so` exports identical C symbols, `vendor.qti.hardware.display.allocator-service` is **completely absent from `/vendor/bin/hw/`** in our built image. When `libEGL_adreno.so` calls `eglInitialize()`, no gralloc allocator service exists to handle `IAllocator/default` requests.

### Controlled Experiment C Plan:
Replace the core gralloc allocation HAL stack with stock ASUS prebuilts:
1. `/vendor/bin/hw/vendor.qti.hardware.display.allocator-service`
2. `/vendor/lib64/hw/gralloc.default.so`
3. `/vendor/lib64/libgrallocutils.so`
4. `/vendor/lib64/hw/android.hardware.graphics.mapper@4.0-impl-qti-display.so`

This aligns the entire gralloc allocator/mapper stack with stock prebuilts for ABI coherence with `libEGL_adreno.so`.
