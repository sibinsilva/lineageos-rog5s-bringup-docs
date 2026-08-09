# 📑 Part 1: Bringup Milestones & System Architecture

## 1. Initial Bringup Phase
The project started with bringing up LineageOS 20.0 (Android 13) for the ASUS ROG Phone 5s (`ZS676KS`) powered by the Snapdragon 888+ (`sm8350`). Initial efforts focused on establishing a booting kernel baseline, valid partition structures, and functional init scripts.

---

## 2. Kernel Integration Baseline
* **Kernel Tree:** `kernel/asus/sm8350`
* **Defconfig:** `kirisakura_defconfig`
* **Vendor Modules:** Display driver module `msm_drm.ko` compiled from source.
* **Module Loading:** Standardized via `BoardConfigCommon.mk` using:
  ```makefile
  BOARD_VENDOR_KERNEL_MODULES_LOAD := msm_drm.ko
  ```

---

## 3. Open-Source Display Stack Migration
Initial bringup builds suffered from display crashes due to conflicts between proprietary OEM vendor blobs and open-source HALs.

* **Architectural Decision:** Migrate to 100% open-source Qualcomm CAF Display HAL (`hardware/qcom-caf/sm8350/display`) on branch `lineage-20.0-caf-sm8350`.
* **Result:** Eliminated all display blobbing in `vendor/asus/rog5s`. Successfully compiled clean `m vendorimage` generating an un-blobbed 1.2GB `vendor.img`.

---

## 4. Multi-Device Commonization Architecture (`rog5-common`)
To support both **ROG Phone 5 (`ZS673KS`)** and **ROG Phone 5s (`ZS676KS`)** without code duplication, the device tree was refactored into the official LineageOS commonized architecture:

```text
/mnt/android-build/device/asus/
├── rog5-common/          <-- (95% Shared Code: Overlays, HIDL, Init, Policy, HALs)
│   ├── BoardConfigCommon.mk
│   ├── device.mk
│   ├── overlay/
│   ├── hidl/
│   └── sepolicy/
├── rog5s/                <-- ROG Phone 5s Specific (< 15 lines)
│   ├── BoardConfig.mk (Inherits BoardConfigCommon.mk)
│   ├── device.mk (Inherits common device.mk)
│   └── prebuilts/ (DTB/DTBO)
└── rog5/                 <-- ROG Phone 5 Specific (< 15 lines)
    ├── BoardConfig.mk (Inherits BoardConfigCommon.mk)
    ├── device.mk (Inherits common device.mk)
    └── prebuilts/ (DTB/DTBO)
```

---

## 5. Repository Ecosystem Overview
* **`device/asus/rog5-common`:** [android_device_asus_rog5-common](https://github.com/sibinsilva/android_device_asus_rog5-common)
* **`device/asus/rog5s`:** [android_device_asus_rog5s](https://github.com/sibinsilva/android_device_asus_rog5s)
* **`device/asus/rog5`:** [android_device_asus_rog5](https://github.com/sibinsilva/android_device_asus_rog5)
* **`vendor/asus/rog5s`:** [android_vendor_asus_rog5s](https://github.com/sibinsilva/android_vendor_asus_rog5s)
* **`kernel/asus/sm8350`:** [android_kernel_asus_sm8350](https://github.com/sibinsilva/android_kernel_asus_sm8350)
