# ASUS ROG Phone 5S (`rog5s`) — Display Stack & Gralloc Hacks Audit Matrix

## Executive Summary
This document records the exact 100% stock-verified display stack components and 32-bit gralloc dependencies staged into the device build tree (`out/target/product/rog5s/vendor/`).

---

## Mandatory Verification Protocol Rules
1. **Stock Binary Parity:** Every staged binary/library must match stock ROM dump MD5.
2. **Build Tree Gating Audit:** Every staged binary/library MUST be cross-referenced against `rog5s-vendor.mk` (`PRODUCT_COPY_FILES`). Any module disabled/commented out in the build tree (such as `vendor.pixelworks.hardware.display.iris-service`) MUST NOT be manually staged into `OUT`, as starting disabled services breaks `init` and kills `adbd`.
3. **No Monolithic Overrides:** Do not copy monolithic `manifest.xml` into `/vendor/etc/vintf/manifest/`. Allow AOSP to dynamically compile master VINTF manifests at build time.

---

## Complete Staged Files & MD5 Verification Matrix

### 1. Display Daemons (Binaries)
| Relative Path | Size | Stock Match | Build Gating Status | Description |
|:---|:---:|:---:|:---:|:---|
| `bin/hw/vendor.qti.hardware.display.composer-service` | 668,136 B | ✅ 100% | ✅ Active | Stock QTI HWC & SDM Composer Service |
| `bin/hw/vendor.qti.hardware.display.allocator-service` | 38,776 B | ✅ 100% | ✅ Active | Stock QTI Gralloc Allocator HAL |
| `bin/hw/vendor.pixelworks.hardware.display.iris-service` | — | — | ❌ DISABLED in `rog5s-vendor.mk` | Purged to prevent init crash loop |

---

### 2. Display Stack & Hardware Composer Shared Libraries (64-bit)
| Relative Path | Size | Stock Match | Description |
|:---|:---:|:---:|:---|
| `lib64/vendor.qti.hardware.display.composer@3.0.so` | 338,272 B | ✅ 100% | QTI Composer HIDL Interface |
| `lib64/libsdmcore.so` | 681,256 B | ✅ 100% | SDM Display Core Engine |
| `lib64/libsdedrm.so` | 415,208 B | ✅ 100% | Snapdragon Display Engine DRM Interface |
| `lib64/libgralloccore.so` | 101,280 B | ✅ 100% | Stock 64-bit Gralloc Core |
| `lib64/libgrallocutils.so` | 66,768 B | ✅ 100% | Stock 64-bit Gralloc Utils |
| `lib64/libdrm.so` | 83,032 B | ✅ 100% | QTI DRM Display Library |
| `lib64/libdrmutils.so` | 20,216 B | ✅ 100% | QTI DRM Helper Utils |
| `lib64/libgpu_tonemapper.so` | 67,184 B | ✅ 100% | Adreno GPU Tonemapper |
| `lib64/libhistogram.so` | 46,440 B | ✅ 100% | Display Histogram Library |
| `lib64/libqservice.so` | 67,352 B | ✅ 100% | QTI Display QService |
| `lib64/libmemutils.so` | 15,864 B | ✅ 100% | Memory Alignment & Alloc Utils |
| `lib64/libsdmutils.so` | 55,192 B | ✅ 100% | SDM Helper Utilities |
| `lib64/libqdMetaData.so` | 29,032 B | ✅ 100% | QTI Metadata Handler |
| `lib64/libqdutils.so` | 32,904 B | ✅ 100% | QTI Display Utilities |
| `lib64/libdisplaydebug.so` | 15,720 B | ✅ 100% | Display Debug Logging Interface |

---

### 3. Mapper Implementation & 32-bit Gralloc Libraries
| Relative Path | Size | Stock Match | Description |
|:---|:---:|:---:|:---|
| `lib64/hw/android.hardware.graphics.mapper@4.0-impl-qti-display.so` | 82,288 B | ✅ 100% | 64-bit Mapper 4.0 Impl |
| `lib/hw/android.hardware.graphics.mapper@4.0-impl-qti-display.so` | 54,952 B | ✅ 100% | 32-bit Mapper 4.0 Impl |
| `lib/libgralloccore.so` | 66,392 B | ✅ 100% | **32-bit Gralloc Core** (Resolved `vendor.qti.media.c2` linker crash) |
| `lib/libgrallocutils.so` | 41,868 B | ✅ 100% | **32-bit Gralloc Utils** (Resolved `sphal` mapper dlopen crash) |

---

### 4. Service Init Scripts (`/vendor/etc/init/`)
| Relative Path | Size | Stock Match | Description |
|:---|:---:|:---:|:---|
| `etc/init/vendor.qti.hardware.display.composer-service.rc` | 324 B | ✅ 100% | Composer service init configuration |
| `etc/init/vendor.qti.hardware.display.allocator-service.rc` | 236 B | ✅ 100% | Allocator service init configuration |

---

### 5. VINTF Manifest Fragments (`/vendor/etc/vintf/manifest/`)
| Relative Path | Size | Stock Match | Description |
|:---|:---:|:---:|:---|
| `etc/vintf/manifest/vendor.qti.hardware.display.composer-service.xml` | 2,953 B | ✅ 100% | Composer service VINTF manifest |
| `etc/vintf/manifest/vendor.qti.hardware.display.allocator-service.xml` | 2,203 B | ✅ 100% | Allocator service VINTF manifest |
| `etc/vintf/manifest/android.hardware.graphics.mapper-impl-qti-display.xml` | 2,226 B | ✅ 100% | Stock Mapper 3.0/4.0 VINTF manifest |
