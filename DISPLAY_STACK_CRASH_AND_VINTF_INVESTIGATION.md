# 🔬 Display Subsystem Crash, SELinux, & VINTF Investigation Report

## Executive Summary
This document provides a strict, line-by-line evidence audit of the display stack failures captured in `logcat_bf.txt` (UTF-16, 74,018 lines).

---

## 🔬 Itemized Investigation Findings (`logcat_bf.txt`)

### 1. Item A: Pixelworks Display Feature HAL (`vendor.pixelworks.hardware.feature`)

#### Hard Log Evidence (`logcat_bf.txt` Lines 1531–1538, 3336)
```text
L1531: 08-10 14:43:10.729     1     1 E init    : File /vendor/bin/hw/vendor.pixelworks.hardware.feature.irisfeature-service (labeled "u:object_r:vendor_file:s0") has incorrect label or no domain transition from u:r:init:s0 to another SELinux domain defined. Have you configured your service correctly? https://source.android.com/security/selinux/device-policy#label_new_services_and_address_denials
L1532: 08-10 14:43:10.729     1     1 I init    : starting service 'vendor.pixelworks.hardware.feature'...
L1537: 08-10 14:43:10.737     1     1 I init    : Service 'vendor.pixelworks.hardware.feature' (pid 2347) exited with status 234
L1538: 08-10 14:43:10.737     1     1 I init    : Sending signal 9 to service 'vendor.pixelworks.hardware.feature' (pid 2347) process group...
L3336: 08-10 14:43:20.741     1     1 E init    : process with updatable components 'vendor.pixelworks.hardware.feature' exited 4 times before boot completed
```

#### Diagnostic Breakdown
* **SELinux Labeling Error**: `/vendor/bin/hw/vendor.pixelworks.hardware.feature.irisfeature-service` is labeled generic `vendor_file:s0` in `file_contexts`. Android 13 SELinux policy strictly forbids `init` from executing vendor executables labeled `vendor_file` without an explicit `_exec` label and `init_daemon_domain()` transition.
* **Exit Status 234 (`-EINVAL`)**: Status 234 (signed char `-22` = `-EINVAL`) is returned by `main()` when `defaultPassthroughServiceImplementation` fails binder registration with `hwservicemanager` due to missing VINTF manifest entries or missing `/dev/pwiris6` device permissions.

---

### 2. Item B: Stock ASUS Pixelworks `.rc`, SELinux Contexts, VINTF Declarations & Dependencies

* **Init `.rc` Files**: [`vendor.pixelworks.hardware.feature.irisfeature-service.rc`](file:///mnt/android-build/vendor/asus/rog5s/proprietary/vendor/etc/init/vendor.pixelworks.hardware.feature.irisfeature-service.rc) and `vendor.pixelworks.hardware.display.iris-service.rc` exist and are copied into `/vendor/etc/init/`.
* **Missing VINTF Manifest**: `pixelworks_manifest.xml` is **missing** from `DEVICE_MANIFEST_FILE` in `BoardConfigCommon.mk`. Because `vendor.pixelworks.hardware.feature@1.0` is absent from the target VINTF manifest, `hwservicemanager` denies registration.
* **SELinux Policy**: Missing SELinux domain (`hal_pixelworks_feature`) and file context mappings in `file_contexts`.

---

### 3. Item C: SecDisplay (`vendor.qti.hardware.secdisplay@1.0`) PanelID/Commit & VINTF Missing

#### Hard Log Evidence (`logcat_bf.txt` Lines 34110–34117, 36449)
```text
L34110: 08-10 14:45:46.187 12443 12443 E ssecdisplay: [SecDisplay][readPanelID] open path fail. /sys/devices/platform/soc/894000.spi/spi_master/spi0/spi0.0/PanelID
L34111: 08-10 14:45:46.187 12443 12443 E ssecdisplay: [SecDisplay] open path fail. -1
L34112: 08-10 14:45:46.187 12443 12443 E ssecdisplay: [SecDisplay] open path fail. /sys/devices/platform/soc/894000.spi/spi_master/spi0/spi0.0/Commit
L34113: 08-10 14:45:46.187 12443 12443 E ssecdisplay: [SecDisplay][Init] panel_id:
L34115: 08-10 14:45:46.191   548   548 I hwservicemanager: getTransport: Cannot find entry vendor.qti.hardware.secdisplay@1.0::ISecdisplay/default in either framework or device VINTF manifest.
L34116: 08-10 14:45:46.192 12443 12443 E HidlServiceManagement: Service vendor.qti.hardware.secdisplay@1.0::ISecdisplay/default must be in VINTF manifest in order to register/get.
L34117: 08-10 14:45:46.192 12443 12443 E LegacySupport: Could not register service vendor.qti.hardware.secdisplay@1.0::ISecdisplay/default (-2147483648).
L36449: 08-10 14:45:51.170     1     1 E init    : File /vendor/bin/hw/vendor.qti.hardware.secdisplay@1.0-service (labeled "u:object_r:vendor_file:s0") has incorrect label or no domain transition.
```

#### Diagnostic Breakdown
* **Sysfs Path Access Failure**: The SPI display panel controller sysfs node path (`/sys/devices/platform/soc/894000.spi/spi_master/spi0/spi0.0/PanelID`) is unpopulated in kernel or lacks permissions.
* **Missing VINTF Manifest**: `vendor.qti.hardware.secdisplay@1.0::ISecdisplay/default` is missing from `DEVICE_MANIFEST_FILE`.
* **SELinux Labeling Error**: `/vendor/bin/hw/vendor.qti.hardware.secdisplay@1.0-service` is labeled generic `vendor_file:s0` without domain transition.

---

### 4. Item D: Why `android.hardware.graphics.composer@2.1::IComposer/default` is Not Registered / Started

#### Hard Log Evidence (`logcat_bf.txt` Lines 36470, 36591–36598)
```text
L36470: 08-10 14:45:51.194 12749 12749 I SurfaceFlinger: Using HWComposer service: default
L36591: 08-10 14:45:51.274   548   548 I hwservicemanager: Since android.hardware.graphics.composer@2.1::IComposer/default is not registered, trying to start it as a lazy HAL.
L36595: 08-10 14:45:51.287   548 12781 W libc    : Unable to set property "ctl.interface_start" to "android.hardware.graphics.composer@2.1::IComposer/default": error code: 0x20
L36596: 08-10 14:45:51.287   548 12781 I hwservicemanager: Tried to start android.hardware.graphics.composer@2.1::IComposer/default as a lazy service, but was unable to. Usually this happens when a service is not installed, but if the service is intended to be used as a lazy service, then it may be configured incorrectly.
```

#### Diagnostic Breakdown
* **Init Control Property Failure (`error code: 0x20`)**: When `hwservicemanager` attempts lazy HAL start using `ctl.interface_start`, `init` rejects the command with `error code: 0x20` (`EPERM`/unknown interface) because the composer service `.rc` file does **not** declare `interface android.hardware.graphics.composer@2.1::IComposer default` through `@2.4`.

---

### 5. Item E: Composer Implementation & Library Set Assessment

* All required composer dependencies (`libsdmcore.so`, `libqservice.so`, `libqdutils.so`, `android.hardware.graphics.composer@2.4.so`) exist in `/vendor/lib64/`.
* The primary reason `IComposer/default` is unavailable is **service lifecycle and VINTF configuration**:
  1. The `.rc` file lacks `interface` statements for `ctl.interface_start`.
  2. SELinux executable labels and domain transitions are missing for display services.
  3. SecDisplay and Pixelworks feature HALs crash or fail VINTF registration prior to HWC startup.

---

## 📋 Comprehensive Fix Matrix

| Subsystem Component | Identified Error in Logcat | Root Cause | Required Configuration Fix |
|---|---|---|---|
| **Pixelworks Feature HAL** | Exits status 234 (`-EINVAL`), labeled `vendor_file:s0` | Missing SELinux domain transition & missing VINTF fragment | Create `hal_pixelworks_feature` SELinux domain, file context, & declare in VINTF |
| **SecDisplay HAL** | Sysfs path fail, missing VINTF manifest entry | Missing sysfs path permissions & missing VINTF fragment | Create `vendor.qti.hardware.secdisplay@1.0` VINTF fragment & label executable |
| **Composer HAL** | `ctl.interface_start` error `0x20` | `.rc` file lacks `interface` lines | Add `interface android.hardware.graphics.composer@2.1::IComposer default` lines to `.rc` |
