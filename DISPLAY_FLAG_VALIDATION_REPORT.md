# Display Stack Study & Flag Validation Report
### obiwan (ROG Phone 3) Analysis → Application to ROG Phone 5/5s (SM8350 / lahaina)

---

## Part 1 — How obiwan Implements Display in LineageOS

### 1.1 Device Reference

| Field | Value |
|:---|:---|
| **Device** | ASUS ROG Phone 3 (ZS661KS) |
| **Codename** | `obiwan` |
| **SoC** | Qualcomm SM8250-AB / Snapdragon 865+ (`kona` platform) |
| **Display** | 6.59" Super AMOLED, 1080×2340, 144 Hz, Tianma TA066VVHM03 |
| **LineageOS branch** | `lineage-19.1` (Android 12, last official; now discontinued) |
| **Primary maintainer** | Alessandro Astone (`aleasto` on GitHub) |
| **Our device** | ASUS ROG Phone 5/5s (ZS673KS/ZS676KS), SM8350/Snapdragon 888 |

---

### 1.2 BoardConfig Display Flags (obiwan)

obiwan's `BoardConfig.mk` is intentionally minimal for display — it inherits
the full flag set from `android_device_asus_sm8250-common/BoardConfigCommon.mk`:

```makefile
# Display
TARGET_SCREEN_DENSITY := 420
TARGET_USES_ION := true          # ION unified memory allocator
BOARD_USES_QCOM_HARDWARE := true # Links to hardware/qcom-caf display HALs

# From sm8250-common (inherited):
TARGET_USES_HWC2 := true
TARGET_USES_GRALLOC4 := true
TARGET_USES_DRM_PP := true       # DRM post-processing / SDE pipeline
TARGET_FORCE_HWC_FOR_VIRTUAL_DISPLAYS := true
TARGET_USES_DISPLAY_RENDER_INTENTS := true
NUM_FRAMEBUFFER_SURFACE_BUFFERS := 3
```

---

### 1.3 Display HAL Architecture

```
Application / SurfaceFlinger
        ↓  HIDL HWC 2.4
vendor.qti.hardware.display.composer-service   ← OSS binary (CAF)
        ↓  calls into proprietary
libsdedrm.so / libsdmcore.so                   ← PROPRIETARY Qualcomm SDE blobs
        ↓
Linux DRM/KMS kernel driver (SDE)              ← OSS (kernel source)
        ↓  MIPI DSI
Panel DDIC → Pixelworks Iris co-processor      ← PROPRIETARY HAL daemon
```

---

### 1.4 OSS vs Proprietary — Display Components

#### Open Source (CAF-built)
| Component | Source |
|:---|:---|
| `vendor.qti.hardware.display.composer-service` | `hardware/qcom-caf/sm8250/display` |
| `vendor.qti.hardware.display.allocator-service` | CAF display repo |
| `android.hardware.graphics.mapper@3.0-impl-qti-display` | CAF display / gralloc |
| `android.hardware.graphics.mapper@4.0-impl-qti-display` | CAF display / gralloc |
| `libdisplayconfig.qti`, `libqdMetaData` | CAF display |
| `memtrack.kona` | CAF memtrack |
| DRM/KMS SDE kernel driver | `drivers/gpu/drm/msm/` in kernel source |

#### Proprietary Stock Blobs
| Blob | Role |
|:---|:---|
| `gralloc.kona.so` | Platform-specific Gralloc impl (UBWC allocation) |
| `libsdmcore.so` | Smart Display Manager core — composition, power, panel |
| `libsdedrm.so` | SDE/DRM bridge between composer service and kernel DRM |
| `libsdmutils.so` | SDM utilities |
| `vendor.display.color@1.x.so` | Qualcomm display color post-processing pipeline |
| `vendor.display.postproc@1.0.so` | Display post-processing |
| `vendor.pixelworks.hardware.display@1.0-service` | Pixelworks Iris service |
| `libpxlworks_iris.so` | Pixelworks Iris library |

> **Key insight:** The composer service binary is OSS (CAF), but at runtime it
> calls into proprietary `libsdmcore.so` and `libsdedrm.so`. The pipeline "brains"
> remain closed-source Qualcomm blobs.

---

### 1.5 Pixelworks Iris — Declared in `asus_manifest.xml`

obiwan declares the Pixelworks Iris co-processor HAL in a **device-specific manifest**
separate from the main platform manifest:

```xml
<!-- asus_manifest.xml -->
<hal format="hidl">
    <name>vendor.pixelworks.hardware.display</name>
    <transport>hwbinder</transport>
    <version>1.0</version>
    <interface>
        <name>IIris</name>
        <instance>default</instance>
    </interface>
</hal>
```

And in `asus_framework_matrix.xml` it is marked **`optional="true"`** — meaning
VINTF compatibility check will not fail if Iris hardware is absent:

```xml
<hal format="hidl" optional="true">
    <name>vendor.pixelworks.hardware.display</name>
    <version>1.0</version>
    ...
</hal>
```

**What Pixelworks Iris does:**
- MEMC (Motion Estimation / Motion Compensation) — smooth interpolation on 144Hz
- SDR → HDR upconversion
- Adaptive color calibration and custom visual modes (Cinema, Gaming, Vivid)
- Backlight dimming compensation
- Operates as a dedicated chip between the SoC and the display DDIC

**Relevance to our ROG 5/5s:** The ROG 5 and 5s also ship Pixelworks Iris
(Iris 3 Pro / Iris 5). Our `asus_manifest.xml` already declares this HAL and
our vendor blobs include:
- `vendor/bin/hw/vendor.pixelworks.hardware.display.iris-service`
- `vendor/lib64/vendor.pixelworks.hardware.display@1.0.so`
- `vendor/lib64/vendor.pixelworks.hardware.display@1.1.so`

✅ **Pixelworks Iris is already correctly declared and present in our build.**

---

### 1.6 Display Properties — obiwan `vendor.prop`

```ini
# SDE display engine tuning
vendor.display.comp_mask=0
vendor.display.disable_excl_rect=0
vendor.display.disable_excl_rect_partial_fb=1
vendor.display.disable_idle_time_hdr=1
vendor.display.disable_idle_time_video=1
vendor.display.disable_offline_rotator=1
vendor.display.enable_async_powermode=1
vendor.display.enable_optimize_refresh=1       # Adaptive refresh rate (60↔144 Hz)
vendor.display.enable_posted_start_dyn=1

# SurfaceFlinger high-FPS phase offsets (tuned for 144 Hz)
debug.sf.enable_advanced_sf_phase_offset=1
debug.sf.enable_gl_backpressure=1
debug.sf.high_fps_early_gl_phase_offset_ns=-4000000
debug.sf.high_fps_early_phase_offset_ns=-4000000
debug.sf.high_fps_late_app_phase_offset_ns=1000000
debug.sf.high_fps_late_sf_phase_offset_ns=-4000000
debug.sf.latch_unsignaled=1

# Color / wide gamut
persist.sys.sf.color_mode=9                    # DCI-P3
ro.surface_flinger.has_HDR_display=true
ro.surface_flinger.has_wide_color_display=true
ro.surface_flinger.force_hwc_copy_for_virtual_displays=true
```

---

### 1.7 device.mk — Full Display PRODUCT_PACKAGES

```makefile
# Gralloc mapper chain (both 3.0 and 4.0 for compatibility)
android.hardware.graphics.mapper@3.0-impl-qti-display
android.hardware.graphics.mapper@4.0-impl-qti-display
gralloc.kona                          # platform gralloc impl

# Display config interface libs
libdisplayconfig.qti
libdisplayconfig.system.qti
libqdMetaData
libqdMetaData.system
libtinyxml

# Memtrack
android.hardware.memtrack@1.0-impl
android.hardware.memtrack@1.0-service
memtrack.kona

# Display config HIDL versioned libs
vendor.display.config@1.0
vendor.display.config@1.11.vendor
vendor.display.config@2.0
vendor.display.config@2.0.vendor

# Core display services
vendor.qti.hardware.display.allocator-service
vendor.qti.hardware.display.composer-service

# Mapper vendor passthrough libs (all versions for compat)
vendor.qti.hardware.display.mapper@1.1.vendor
vendor.qti.hardware.display.mapper@2.0.vendor
vendor.qti.hardware.display.mapper@3.0.vendor
vendor.qti.hardware.display.mapper@4.0.vendor

# Color conversion
libc2dcolorconvert
```

---

### 1.8 obiwan vs Our ROG 5/5s — Feature Comparison

| Feature | obiwan (SM8250/kona) | Our rog5s (SM8350/lahaina) | Gap? |
|:---|:---:|:---:|:---:|
| DRM/SDE display stack | ✅ | ✅ | None |
| OSS CAF composer service | ✅ | ✅ | None |
| Proprietary `libsdmcore` + `libsdedrm` | ✅ (kona blobs) | ⚠️ `libsdedrm` missing — needs OSS build | **CAF include fixes** |
| Gralloc 4 (`TARGET_USES_GRALLOC4`) | ✅ | ⚠️ Soong only, Make var missing | **See Part 2** |
| `TARGET_USES_DRM_PP` | ✅ | ❌ Not set | **See Part 2** |
| `TARGET_USES_HWC2` | ✅ | ⚠️ Implicit only | **See Part 2** |
| Pixelworks Iris HAL | ✅ `vendor.pixelworks.hardware.display@1.0` | ✅ Already declared + blobs present | None |
| High-FPS SF phase offsets | ✅ | ❌ Not set in props | To add separately |
| WCG / HDR surface flinger props | ✅ | ❌ Not set | Covered by CAF display-product.mk |
| `enable_optimize_refresh` (adaptive Hz) | ✅ | ❌ Not set | Covered by CAF display-product.mk |

---

## Part 2 — Flag Validation Report
### Proposed flags from obiwan → Are they valid for our ROG 5/5s (SM8350 / lahaina)?

---

## Background

After studying how obiwan (ASUS ROG Phone 3, SM8250/kona) implements display in
LineageOS, three flags were identified as potentially missing from our
`device/asus/rog5-common/BoardConfigCommon.mk`:

1. `TARGET_USES_GRALLOC4 := true`
2. `TARGET_USES_HWC2 := true`
3. `TARGET_USES_DRM_PP := true`

This report validates each flag against our actual SM8350 CAF display source,
our vendor blobs, and our current build configuration before any change is made.

---

## Evidence Base

| Source | Path |
|:---|:---|
| CAF SM8350 display board config | `hardware/qcom-caf/sm8350/display/config/display-board.mk` |
| CAF SM8350 display product config | `hardware/qcom-caf/sm8350/display/config/display-product.mk` |
| Our current board config | `device/asus/rog5-common/BoardConfigCommon.mk` |
| Our current device.mk | `device/asus/rog5-common/device.mk` |
| Our vendor blobs | `vendor/asus/rog5s/proprietary/vendor/` |
| Reference device (obiwan/kona) | `LineageOS/android_device_asus_obiwan @ lineage-19.1` |

---

## Flag 1: `TARGET_USES_GRALLOC4 := true`

### What it does
Switches the Gralloc HAL from the legacy Gralloc 1/3 interface to the
**Gralloc 4.0** HIDL interface (`android.hardware.graphics.allocator@4.0`
+ `android.hardware.graphics.mapper@4.0`). It also gates C++ code inside
`hardware/qcom-caf/sm8350/display/gralloc/service.cpp` via
`#ifdef TARGET_USES_GRALLOC4`.

Additionally, the CAF display Soong build system reads this via:
```makefile
SOONG_CONFIG_qtidisplay_gralloc4 := true
```
which controls whether `gralloc4`-path modules are compiled.

### Is it defined in the SM8350 CAF display?
```
hardware/qcom-caf/sm8350/display/config/display-board.mk:
    TARGET_USES_GRALLOC4 := true   ← YES, hardcoded for SM8350
```

### Do we already partially have it?
**YES — partially.** Our `BoardConfigCommon.mk` has:
```makefile
SOONG_CONFIG_NAMESPACES += qtidisplay
SOONG_CONFIG_qtidisplay += default gralloc4
```
But the **raw Make variable** `TARGET_USES_GRALLOC4 := true` is **NOT set**.
This means the Soong namespace is configured, but any legacy Makefile code
guarded by `ifeq ($(TARGET_USES_GRALLOC4),true)` will not fire.

### Do our vendor blobs require Gralloc 4?
**YES.** Our device.mk already lists:
```makefile
vendor.qti.hardware.display.mapper@4.0.vendor
vendor.qti.hardware.display.mapper@3.0.vendor
vendor.qti.hardware.display.mapper@2.0.vendor
vendor.qti.hardware.display.mapper@1.1.vendor
```
The `@4.0.vendor` mapper is the Gralloc 4 mapper passthrough lib.
Our vendor also ships `android.hardware.graphics.mapper@4.0-impl-qti-display`
via the OSS CAF display build.

### Verdict
> ✅ **VALID AND REQUIRED** — The SM8350 CAF display code hardcodes this flag,
> our Soong namespace is partially set but the Make variable is missing.
> Adding `TARGET_USES_GRALLOC4 := true` completes the picture and enables
> the correct Gralloc 4 code path in `display/gralloc/service.cpp`.

---

## Flag 2: `TARGET_USES_HWC2 := true`

### What it does
Tells the build system to use the **Hardware Composer 2.x** interface instead
of the legacy HWC 1.x. On Android 12+ (LineageOS 19+), HWC2 is the only
supported interface — HWC1 is removed. The flag is consumed by:
- CAF display source to enable HWC2-specific code paths
- `android.hardware.graphics.composer@2.4-service` binary build conditions

### Is it defined in the SM8350 CAF display?
```
hardware/qcom-caf/sm8350/display/config/display-board.mk:
    TARGET_USES_HWC2 := true   ← YES, hardcoded for SM8350
```

### Is it already implied?
On Android 12 / LineageOS 20, `BoardConfigMainlineCommon.mk` (which we
include) sets `TARGET_USES_HWC2 := true` implicitly for all GKI devices.
However, relying on implicit inheritance is fragile — explicit declaration
is always safer and is what all peer devices do.

### Does it conflict with anything in our tree?
No. We have no `TARGET_USES_HWC2 := false` anywhere. It is safe to add.

### Verdict
> ✅ **VALID — safe to add explicitly.** While likely already true via
> `BoardConfigMainlineCommon.mk`, explicitly declaring it matches the CAF
> display-board.mk expectation and mirrors all working SM8350 peers.

---

## Flag 3: `TARGET_USES_DRM_PP := true`

### What it does
Enables **DRM Post-Processing** — the kernel-level SDE (Smart Display Engine)
display post-processing pipeline. This enables:
- Color management via the DRM/KMS `PP` (post-processor) hardware block
- `libsdedrm.so` build from CAF display source (the SDE/DRM bridge library)
- `libdrmutils` build
- `libgpu_tonemapper` build

In `display-product.mk` this is gated:
```makefile
PRODUCT_PACKAGES += libdrmutils
PRODUCT_PACKAGES += libsdedrm
PRODUCT_PACKAGES += libgpu_tonemapper
```
These packages are only added when `TARGET_IS_HEADLESS != true`, which is
controlled downstream by `TARGET_USES_DRM_PP`.

### Is it defined in the SM8350 CAF display?
```
hardware/qcom-caf/sm8350/display/config/display-board.mk:
    TARGET_USES_DRM_PP := true   ← YES, hardcoded for SM8350
```

### Do our vendor blobs require it?
**Indirectly YES.** Our vendor has:
- `libsdm-color.so`, `libsdm-diag.so`, `libsdm-disp-vndapis.so` — these are
  the proprietary SDM display blobs that sit above the DRM PP layer
- `vendor.display.color@1.0-service` — this is the display color service that
  depends on DRM PP being active for its hardware color pipeline

### Critical question: does our kernel support DRM PP?
**YES.** Our kernel (`kernel/asus/sm8350`, Kirisakura, Linux 5.4.210) is based
on the Qualcomm SM8350 BSP which includes the full SDE DRM driver at
`drivers/gpu/drm/msm/sde/`. The SDE driver includes the PP hardware block
interface (`sde_hw_color_processing.c`, `sde_hw_dspp.c`).

### Verdict
> ✅ **VALID AND REQUIRED** — The SM8350 CAF display hardcodes this. Our
> proprietary display color blobs depend on DRM PP being active. Our kernel
> supports it. Without this flag, `libsdedrm` may not be built from OSS
> CAF source, leaving a gap that the OSS composer service depends on.

---

## Flag 4: Additional flags in SM8350 display-board.mk (not from obiwan)

The SM8350 `display-board.mk` also sets flags that obiwan (kona) does NOT have,
but which are specific to SM8350. These should also be evaluated:

| Flag | Value | Needed? |
|:---|:---|:---|
| `TARGET_USES_QCOM_DISPLAY_BSP` | `true` | ✅ Yes — SM8350-specific display BSP flag |
| `TARGET_USES_COLOR_METADATA` | `true` | ✅ Yes — enables UBWC color metadata in Gralloc |
| `TARGET_HAS_WIDE_COLOR_DISPLAY` | `true` | ✅ Yes — our AMOLED is WCG |
| `TARGET_HAS_HDR_DISPLAY` | `true` | ✅ Yes — our AMOLED supports HDR10 |
| `TARGET_USES_DISPLAY_RENDER_INTENTS` | `true` | ✅ Yes — per-intent color management |
| `TARGET_USE_COLOR_MANAGEMENT` | `true` | ✅ Yes — SF color management |
| `SF_WCG_COMPOSITION_DATA_SPACE` | `143261696` | ✅ Yes — WCG dataspace for SF |
| `TARGET_USES_QTI_MAPPER_2_0` | `true` | ✅ Yes — QTI mapper 2.0 passthrough |
| `TARGET_USES_QTI_MAPPER_EXTENSIONS_1_1` | `true` | ✅ Yes — QTI mapper extensions |
| `TARGET_FORCE_HWC_FOR_VIRTUAL_DISPLAYS` | `true` | ✅ Yes — screen recording via HWC |
| `MAX_VIRTUAL_DISPLAY_DIMENSION` | `4096` | ✅ Yes — max virtual display size |
| `NUM_FRAMEBUFFER_SURFACE_BUFFERS` | `3` | ✅ Yes — triple buffering |

> ⚠️ **Finding:** The SIMPLEST and MOST CORRECT approach is to just include
> the CAF-provided `display-board.mk` directly, rather than manually
> declaring each flag. This is the approach used by most SM8350 peer devices.

---

## The Correct Approach: Include CAF display-board.mk

Instead of adding flags one-by-one, the proper pattern is:

```makefile
# In BoardConfigCommon.mk
include hardware/qcom-caf/sm8350/display/config/display-board.mk
```

And in `device.mk`:
```makefile
include hardware/qcom-caf/sm8350/display/config/display-product.mk
```

### Why this is better than manual flags:
1. Gets ALL SM8350 display flags at once — no risk of missing any
2. Automatically stays in sync if CAF display updates its requirements
3. Is the documented/intended integration path for QTI CAF display
4. Avoids manual duplication errors

### Does `display-product.mk` conflict with our existing device.mk?

**Potential conflicts to check:**

| display-product.mk entry | Our device.mk | Safe? |
|:---|:---|:---|
| Adds `libsdedrm`, `libdrmutils` | Not listed — would be new | ✅ Safe to add |
| Adds `libgpu_tonemapper` | Not listed | ✅ Safe to add |
| Sets `PRODUCT_SOONG_NAMESPACES += $(DISPLAY_HAL_DIR)` | We already add `hardware/qcom-caf/sm8350/display` | ⚠️ Would duplicate — harmless (`+=` is additive) |
| Sets `SOONG_CONFIG_qtidisplay_*` keys | We partially set these | ⚠️ Would override our partial settings — with correct values |
| Sets `ro.surface_flinger.*` properties | We don't set these yet | ✅ Safe to add |
| Adds QDCM calibration XML copy-files | Not present — would be new | ✅ Safe (lahaina-path is used for SM8350) |

### One real conflict: `SOONG_CONFIG_qtidisplay`

Our `BoardConfigCommon.mk` currently has:
```makefile
SOONG_CONFIG_NAMESPACES += qtidisplay
SOONG_CONFIG_qtidisplay += default gralloc4
```

The CAF `display-board.mk` would set:
```makefile
SOONG_CONFIG_qtidisplay := drmpp headless llvmsa gralloc4 udfps default
```

Using `:=` (assignment) after our `+=` (append) means the CAF file would
**override** our partial definition with the complete one. This is actually
**desirable** — we want all Soong keys, not just `default gralloc4`.

**Resolution:** Remove our manual `SOONG_CONFIG_qtidisplay` lines and let
the CAF include handle it completely.

---

## Summary & Recommendation

| Action | Risk | Benefit |
|:---|:---|:---|
| Add `TARGET_USES_GRALLOC4 := true` alone | 🟡 Low | Fixes Gralloc 4 Make path |
| Add `TARGET_USES_HWC2 := true` alone | 🟢 None | Explicit safety, no change |
| Add `TARGET_USES_DRM_PP := true` alone | 🟡 Low | Enables libsdedrm build |
| **Include `display-board.mk` + `display-product.mk`** | 🟡 Low | ✅ **Complete, correct, maintainable** |

> [!IMPORTANT]
> **Recommended action:** Include both CAF `display-board.mk` and
> `display-product.mk` and remove our manual partial `SOONG_CONFIG_qtidisplay`
> lines. This is the cleanest, most complete approach.

> [!NOTE]
> Before applying: verify that `display-product.mk` does not double-declare
> packages already in our `device.mk` in a way that causes `BUILD_BROKEN_DUP_RULES`
> errors. Since we already have `BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true`,
> duplicate PRODUCT_PACKAGES via `+=` are safe (they just deduplicate at link time).

> [!WARNING]
> Do **not** include `display-product.mk` if it pulls in `libsdedrm` as an
> OSS-rebuilt target while our vendor has a pre-built `libsdedrm.so`. Check
> whether our vendor ships `libsdedrm.so` before enabling the OSS build.
> **Current status:** Our vendor does NOT ship `libsdedrm.so` — it is only
> present in the OSS CAF build. This means including `display-product.mk`
> is safe and actually **fills a gap**.
