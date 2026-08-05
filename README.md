# 📚 LineageOS 20.0 (Android 13) Bring-Up Artifacts & Technical Audits
## Target Device: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888+ SM8350)

This repository contains the complete chronological collection of **52 technical audits, architectural reports, hardware logs, and pre-flash verification documents** produced during the LineageOS bring-up and display subsystem restoration for the ASUS ROG Phone 5S.

---

## 📑 Complete Document Index

### 1. Display Subsystem & Qualcomm CAF Architecture
- [`UPSTREAM_CAF_DISPLAY_PREFLASH_VERIFICATION.md`](UPSTREAM_CAF_DISPLAY_PREFLASH_VERIFICATION.md) — Pre-flash verification report & binary dependency audit (`readelf -d`) for CAF HWC3 & Gralloc 4.0.
- [`LINEAGEOS_SM8350_DISPLAY_STACK_AUDIT.md`](LINEAGEOS_SM8350_DISPLAY_STACK_AUDIT.md) — Git history and architecture audit of LineageOS SM8350 display stack (`lemonade`, `sake`).
- [`SM8350_DISPLAY_STACK_COMPARISON.md`](SM8350_DISPLAY_STACK_COMPARISON.md) — Detailed comparison of SM8350 display HAL configurations across official LineageOS devices.
- [`ASUS_DISPLAY_BUILD_GRAPH_AUDIT.md`](ASUS_DISPLAY_BUILD_GRAPH_AUDIT.md) — Build graph audit comparing makefile inclusion chains between `sake` and `rog5s`.
- [`SOONG_GATING_DISPLAY_AUDIT.md`](SOONG_GATING_DISPLAY_AUDIT.md) — Dependency graph demonstrating how Qualcomm CAF display modules are gated by Soong config namespaces.
- [`COMPLETE_BUILD_INHERITANCE_AUDIT.md`](COMPLETE_BUILD_INHERITANCE_AUDIT.md) — 10-stage build inheritance chain trace comparing `sake` vs `rog5s`.
- [`EVIDENCE_BASED_DISPLAY_INVESTIGATION.md`](EVIDENCE_BASED_DISPLAY_INVESTIGATION.md) — Git history investigation of ROG 5/5S display stack decisions.
- [`DISPLAY_CONFIG_AND_PANEL_AUDIT.md`](DISPLAY_CONFIG_AND_PANEL_AUDIT.md) — Display configuration and Samsung AMS678 AMOLED panel audit.
- [`GRAPHICS_ALLOCATION_AUDIT.md`](GRAPHICS_ALLOCATION_AUDIT.md) — Memory allocation and Gralloc 4.0 buffer management audit.

### 2. Runtime & Boot Mechanics
- [`LIVE_BOOT_ROOT_CAUSE_ANALYSIS.md`](LIVE_BOOT_ROOT_CAUSE_ANALYSIS.md) — Analysis of early boot hangs and SurfaceFlinger / RenderEngine initialization order.
- [`EGL_AND_GRALLOC_AUDIT.md`](EGL_AND_GRALLOC_AUDIT.md) — EGL initialize & GPU driver loading audit (`EGL_BAD_DISPLAY`).
- [`EGL_RUNTIME_INVESTIGATION.md`](EGL_RUNTIME_INVESTIGATION.md) — Runtime EGL initialization traces and RenderEngine dependencies.
- [`EARLY_ADB_AND_INIT_AUDIT.md`](EARLY_ADB_AND_INIT_AUDIT.md) — Early boot ADB, USB FunctionFS (`a600000.dwc3`), and init script audit.
- [`CONTROLLED_BRINGUP_PROTOCOL.md`](CONTROLLED_BRINGUP_PROTOCOL.md) — Single-hypothesis controlled bring-up protocol and progression checklist.
- [`RUNTIME_INTEGRATION_AUDIT.md`](RUNTIME_INTEGRATION_AUDIT.md) — Multi-service Binder/HIDL runtime integration audit.
- [`RUNTIME_CORRELATION_REPORT.md`](RUNTIME_CORRELATION_REPORT.md) — Logcat and dmesg runtime correlation report.
- [`RUNTIME_CRITICALITY_RANKING.md`](RUNTIME_CRITICALITY_RANKING.md) — Service criticality ranking for Android userspace bring-up.

### 3. Kernel & Hardware Verification
- [`KERNEL_ARTIFACT_COMPARISON_REPORT.md`](KERNEL_ARTIFACT_COMPARISON_REPORT.md) — Comparison of standalone Kirisakura kernel vs LineageOS compiled kernel.
- [`KERNEL_DRM_RESOURCE_ENUMERATION_AUDIT.md`](KERNEL_DRM_RESOURCE_ENUMERATION_AUDIT.md) — DRM/KMS resource enumeration and MSM DRM driver audit.
- [`ANDROID_BOOT_DMESG_ANALYSIS.md`](ANDROID_BOOT_DMESG_ANALYSIS.md) — Deep dmesg log analysis of kernel boot sequence.
- [`CMDLINE_COMPARISON.md`](CMDLINE_COMPARISON.md) — Kernel command line (`cmdline`) comparison between stock and custom boot images.
- [`KIRISAKURA_COMPARISON_REPORT.md`](KIRISAKURA_COMPARISON_REPORT.md) — Analysis of Kirisakura custom kernel integration.
- [`PHASE_4_DTS_COMPARISON.md`](PHASE_4_DTS_COMPARISON.md) — Device tree source (DTS/DTB) comparison report.

### 4. Build System & Dependency Analysis
- [`BINARY_DEPENDENCY_AUDIT_REPORT.md`](BINARY_DEPENDENCY_AUDIT_REPORT.md) — `readelf -d` dynamic library dependency matrix across vendor binaries.
- [`USERSPACE_DEPENDENCY_AUDIT.md`](USERSPACE_DEPENDENCY_AUDIT.md) — Shared library resolution and missing symbol audit.
- [`VNDK_AND_SERVICE_AUDIT.md`](VNDK_AND_SERVICE_AUDIT.md) — VNDK version compatibility and service binder registration.
- [`SYSTEMATIC_LINK_REPORT.md`](SYSTEMATIC_LINK_REPORT.md) — Detailed linkage map of Android vendor libraries.
- [`PREBUILT_MODULE_REGISTRY.md`](PREBUILT_MODULE_REGISTRY.md) — Registry of stock prebuilt vendor blobs.
- [`CONFLICT_RESOLUTION_REPORT.md`](CONFLICT_RESOLUTION_REPORT.md) — Comprehensive conflict resolution matrix across tree imports.

### 5. Staging & Flash Protocols
- [`PREFLASH_VERIFICATION.md`](PREFLASH_VERIFICATION.md) — Pre-flash safety and integrity checks.
- [`PREFLASH_DOCUMENTATION_MATRIX.md`](PREFLASH_DOCUMENTATION_MATRIX.md) — Pre-flash documentation matrix.
- [`FULL_BUILD_FLASH_PLAN.md`](FULL_BUILD_FLASH_PLAN.md) — Step-by-step flashing plan for full builds.
- [`FINAL_BUILD_REPORT.md`](FINAL_BUILD_REPORT.md) — Summary report of build compilation outputs.
- [`FINAL_POST_BUILD_AUDIT.md`](FINAL_POST_BUILD_AUDIT.md) — Post-build output validation.
- [`RAMDISK_LAYOUT_COMPARISON.md`](RAMDISK_LAYOUT_COMPARISON.md) — First-stage and second-stage ramdisk layout comparison.
- [`VENDOR_BOOT_ANALYSIS.md`](VENDOR_BOOT_ANALYSIS.md) — Vendor boot header and ramdisk structure analysis.
- [`AVB_HASH_ERROR_ANALYSIS.md`](AVB_HASH_ERROR_ANALYSIS.md) — Android Verified Boot (AVB) hash footer analysis.
- [`CAMX_CRASH_ANALYSIS.md`](CAMX_CRASH_ANALYSIS.md) — Qualcomm CamX camera HAL crash analysis.
- [`FIRMWARE_INVESTIGATION_REPORT.md`](FIRMWARE_INVESTIGATION_REPORT.md) — Modem and ADSP firmware load audit.

---

## 🛠️ Hardware Specifications
* **SoC**: Qualcomm Snapdragon 888+ (`SM8350-AC` / `lahaina`)
* **Display**: Samsung AMS678 144Hz AMOLED (`FHD+` / DSC Command Mode)
* **Display Co-Processor**: Pixelworks Iris 6 (`PXLW_IRIS_DUAL`)
* **Base Architecture**: LineageOS 20.0 (`Android 13` / Linux 5.4)
