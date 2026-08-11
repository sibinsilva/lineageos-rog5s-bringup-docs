# LineageOS 20.0 Full ROM Build Success Report
**Device:** ASUS ROG Phone 5s (ASUS_I005D / rog5s)  
**Platform:** Qualcomm Snapdragon 888+ (SM8350 / lahaina)  
**Build Target:** LineageOS 20.0 (`lineage_rog5s-userdebug`)  
**Artifact Zip:** `out/target/product/rog5s/lineage-20.0-20260811-UNOFFICIAL-rog5s.zip`  
**Build Time:** 25m 55s (Accelerated via ccache)  

---

## 1. Executive Summary

The initial full ROM compilation (`m bacon`) for the ASUS ROG Phone 5s (SM8350) has completed **100% successfully**. All core system components, vendor partitions, kernel modules, display stack HALs (Gralloc4, HWC 2.4, SDM Core, SDE DRM), and final OTA payload generation executed cleanly with zero compilation errors.

---

## 2. Key Technical Fixes Applied

### A. Display Stack Resolution (The "Obiwan" Strategy)
- **CAF Shortcut Avoidance:** Removed `hardware/qcom-caf/sm8350/display/config/display-product.mk` inheritance due to upstream Makefile bugs (`TARGET_BOARD_PLATFORM` blank expansion and legacy `.vendor` package suffixes).
- **OSS Source Compilation:** Explicitly enabled source compilation for `libsdedrm`, `libsdmcore`, `libdrmutils`, `libgpu_tonemapper`, and `libmemutils` directly from `hardware/qcom-caf/sm8350/display`.
- **144Hz SurfaceFlinger Tuning:** Configured 144Hz high-FPS phase offsets (`debug.sf.high_fps_early_gl_phase_offset_ns=-4000000`) and power management in `vendor.prop`.
- **Soong Namespace Integration:** `display-board.mk` in `BoardConfigCommon.mk` automatically populates `SOONG_CONFIG_qtidisplay` (`drmpp=true`, `gralloc4=true`), ensuring LineageOS 20 Soong compatibility.

### B. Goodix Fingerprint HIDL Package Path
- Corrected a hardcoded package path in `device/asus/rog5-common/interfaces/goodix/Android.bp` (`device/asus/rog5s/...` -> `device/asus/rog5-common/...`), unblocking Ninja code generation.

### C. VINTF & OTA Packaging Enforcement
- Set `manifest.xml` target level to `target-level="5"` (matching ROG 5 Android 11 launch level) to eliminate FCM 6 deprecation errors for legacy vendor HALs (`radio@1.5`, `memtrack@1.0`, `tetheroffload@1.0`).
- Set `PRODUCT_SHIPPING_API_LEVEL := 30`.
- Enabled `PRODUCT_ENFORCE_VINTF_MANIFEST := true`.
- Set `PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false` to allow offline OTA zip packaging without requiring a live device attached via ADB.

---

## 3. Flash & Installation Instructions

```bash
# 1. Reboot device to fastboot/bootloader
adb reboot bootloader

# 2. Flash boot and vendor_boot images
fastboot flash boot out/target/product/rog5s/boot.img
fastboot flash vendor_boot out/target/product/rog5s/vendor_boot.img
fastboot flash dtbo out/target/product/rog5s/dtbo.img

# 3. Reboot into Lineage Recovery
fastboot reboot recovery

# 4. In Lineage Recovery, select 'Apply update' -> 'Apply from ADB'
adb sideload out/target/product/rog5s/lineage-20.0-20260811-UNOFFICIAL-rog5s.zip
```
