# 🔬 Deep Investigation: Kernel vs HAL Bandwidth Limit ABI Contract

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `rog5s` / SM8350 `lahaina`)  
**Kernel**: Kirisakura `5.4.210-qgki-perf` (`kernel/asus/sm8350`)  
**Date**: August 11, 2026  
**Status**: INVESTIGATION COMPLETE (Read-Only Analysis)

---

## 📌 Executive Summary

An audit was performed to test the hypothesis that the Kirisakura kernel (`5.4.210-qgki-perf`) implements an older single-limit bandwidth scheme that conflicts with the per-mode bandwidth limits expected by the display HAL.

### Key Audit Findings:
1. **Kernel Driver Exposes Dual Bandwidth Limits**:
   In [`kernel/asus/sm8350/techpack/display/msm/sde/sde_crtc.c`](file:///mnt/android-build/kernel/asus/sm8350/techpack/display/msm/sde/sde_crtc.c#L5249-L5254), the Kirisakura kernel display driver explicitly exposes per-mode bandwidth limits:
   * `"max_bandwidth_low"`: `catalog->perf.max_bw_low * 1000LL`
   * `"max_bandwidth_high"`: `catalog->perf.max_bw_high * 1000LL`

2. **Display HAL Parses Dual Bandwidth Limits**:
   In [`hardware/qcom-caf/sm8350/display/sdm/libs/core/drm/hw_info_drm.cpp`](file:///mnt/android-build/hardware/qcom-caf/sm8350/display/sdm/libs/core/drm/hw_info_drm.cpp#L310-L316), `libsdmcore` reads these exact dual limits into the `kBwVFEOn` and `kBwVFEOff` bandwidth modes:
   ```cpp
   for (int index = 0; index < kBwModeMax; index++) {
     if (index == kBwVFEOn) {
       hw_resource->dyn_bw_info.total_bw_limit[index] = info.max_bandwidth_low / kKiloUnit;
     } else if (index == kBwVFEOff) {
       hw_resource->dyn_bw_info.total_bw_limit[index] = info.max_bandwidth_high / kKiloUnit;
     }
   }
   ```

3. **Conclusion**:
   The Kirisakura kernel (`5.4.210-qgki-perf`) and the SM8350 display HAL share the **exact same dual-limit bandwidth ABI contract**. There is **no kernel↔vendor-HAL bandwidth mismatch**.

4. **Actual Root Cause of Logcat Crash**:
   The `SIGABRT` crash in today's `logcat.txt` was caused 100% by the C++ struct layout mismatch in `libsdmextension.so` (`hw_info_types.h#L335` `tap_points` vector shift), not by a kernel bandwidth driver discrepancy.
