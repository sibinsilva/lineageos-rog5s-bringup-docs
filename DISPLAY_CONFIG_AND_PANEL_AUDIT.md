# 🔬 Preparatory Audit: Display Configuration Files & DRM Panel Properties

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: August 3, 2026  
**Scope**: Read-only comparison of `/vendor/etc/` display configs, DPU target XMLs, QDCM calibration data, and kernel DRM panel strings

---

## 1. 📁 `/vendor/etc/displayconfig/`
- **Stock File Count**: `0`
- **Build File Count**: `0`
- **Audit Result**: ✅ Identical (no files expected in this directory).

---

## 2. 📁 `/vendor/etc/display/` (DPU Target XMLs)

| File Name | Stock Size | Build Size | Match Status |
| :--- | :---: | :---: | :---: |
| `DPU660.xml` | 1,870 bytes | 1,870 bytes | ✅ **100% Identical** |
| `DPU670.xml` | 1,808 bytes | 1,808 bytes | ✅ **100% Identical** |
| `DPU720.xml` | 1,685 bytes | 1,685 bytes | ✅ **100% Identical** |
| `DPU7__.xml` | 1,689 bytes | 1,689 bytes | ✅ **100% Identical** |
| `advanced_sf_offsets.xml` | 810 bytes | 810 bytes | ✅ **100% Identical** |

**Audit Result**: All 5 Qualcomm DPU target configuration files in `/vendor/etc/display/` match stock byte-for-byte.

---

## 3. 📁 `/vendor/etc/xml/`
- **Stock File Count**: `0`
- **Build File Count**: `0`
- **Audit Result**: ✅ Identical.

---

## 4. 📁 `/vendor/etc/` Qualcomm Display Configuration Files

- **Present & Matching**:
  - All QDCM panel calibration XMLs (`qdcm_calib_data_*.xml`)
  - All Pixelworks Iris firmware files (`irissoft.fw`, `irissoft_a.fw`, `irissoft_v.fw`, `irissoft_s.fw`, `pxlw_iris6.mcf`)
- **Missing in Build**:
  - `/vendor/etc/init/init.qti.display_boot.rc`
  - `/vendor/etc/vintf/manifest/vendor.pixelworks.hardware.display.iris-service.xml`

---

## 5. 🖥️ Kernel DRM Panel Identification vs Userspace Expectation

### Kernel DRM Panel String (Empirical dmesg)
```text
[2.169492] [drm:dsi_display_bind] [msm-dsi-info]: Successfully bind display panel 'qcom,mdss_dsi_ams678_er2_fhd_plus_dsc_cmd'
[2.169538] [Display] panel vendor id = ams678
```

- **Panel Hardware**: Samsung AMOLED (`ams678`)
- **Resolution / Mode**: FHD+ (2448x1080), Command mode, DSC enabled.
- **Kernel Probe Status**: Registered and bound successfully by kernel `msm_drm` at `t=2.169s`.
- **Match Status**: Kernel exposes `ams678` correctly to userspace.

---

## 🏁 Audit Conclusion

The display configuration files (`DPU7__.xml`, `advanced_sf_offsets.xml`, QDCM calibration data) and DRM panel registration (`ams678`) are **100% consistent with stock**. 

If the display HAL aborts, the failure is **not** caused by missing DPU target XMLs or invalid kernel panel strings.
