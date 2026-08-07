# 📱 Standalone OEM Display Stack Prebuilt Repository Audit (`hardware/qcom-caf/sm8350/display`)

## 1. Executive Summary

To eliminate open-source CAF display HAL build graph conflicts and guarantee 100% stock OEM display hardware acceleration (144Hz refresh rate, Pixelworks Iris 6 co-processor acceleration, and Qualcomm SDM color management), the entire open-source CAF display stack at `hardware/qcom-caf/sm8350/display` has been replaced with a self-contained stock OEM prebuilt repository.

This repository tracks as `hardware/qcom-caf/sm8350/display` in Git (repo name: `android_hardware_qcom-caf_sm8350_display`), allowing developers to simply delete the default CAF display folder and `git clone` or specify it in local manifests (`.repo/local_manifests/`).

---

## 2. Repository Git Information

* **Repository Path**: `hardware/qcom-caf/sm8350/display`
* **Branch**: `master`
* **Initial Commit Hash**: `cefecf9`
* **Commit Message**: `sm8350: display: Import stock ASUS OEM display stack prebuilts for ROG Phone 5S`
* **Total Tracked Files**: 22

---

## 3. Directory Layout & File Registry

```
hardware/qcom-caf/sm8350/display/
├── Android.bp               # Soong prebuilt module definitions
├── display-product.mk       # Standard CAF product package inheritance
├── display-vendor.mk        # Vendor package inheritance alias
├── bin/                     # Hardware service daemons
│   ├── vendor.qti.hardware.display.composer-service
│   ├── vendor.pixelworks.hardware.display.iris-service
│   └── vendor.qti.hardware.display.allocator-service
├── etc/
│   ├── init/                # Service init scripts (.rc)
│   │   ├── vendor.qti.hardware.display.composer-service.rc
│   │   ├── vendor.pixelworks.hardware.display.iris-service.rc
│   │   └── vendor.qti.hardware.display.allocator-service.rc
│   └── vintf/manifest/      # VINTF compatibility manifests (.xml)
│       ├── vendor.qti.hardware.display.composer-service.xml
│       ├── vendor.pixelworks.hardware.display.iris-service.xml
│       └── vendor.qti.hardware.display.allocator-service.xml
└── lib64/                   # Display HAL shared libraries (.so)
    ├── libsdmcore.so
    ├── libgralloccore.so
    ├── libgrallocutils.so
    ├── libdisplaydebug.so
    ├── libdrmutils.so
    ├── libsdedrm.so
    ├── libgpu_tonemapper.so
    ├── libhistogram.so
    ├── libqservice.so
    └── vendor.qti.hardware.display.composer@3.0.so
```

---

## 4. `Android.bp` Module Configuration

```bp
soong_namespace {
}

cc_prebuilt_binary {
    name: "vendor.qti.hardware.display.composer-service",
    srcs: ["bin/vendor.qti.hardware.display.composer-service"],
    init_rc: ["etc/init/vendor.qti.hardware.display.composer-service.rc"],
    vintf_fragments: ["etc/vintf/manifest/vendor.qti.hardware.display.composer-service.xml"],
    vendor: true,
    prefer: true,
}

cc_prebuilt_binary {
    name: "vendor.pixelworks.hardware.display.iris-service",
    srcs: ["bin/vendor.pixelworks.hardware.display.iris-service"],
    init_rc: ["etc/init/vendor.pixelworks.hardware.display.iris-service.rc"],
    vintf_fragments: ["etc/vintf/manifest/vendor.pixelworks.hardware.display.iris-service.xml"],
    vendor: true,
    prefer: true,
}

cc_prebuilt_binary {
    name: "vendor.qti.hardware.display.allocator-service",
    srcs: ["bin/vendor.qti.hardware.display.allocator-service"],
    init_rc: ["etc/init/vendor.qti.hardware.display.allocator-service.rc"],
    vintf_fragments: ["etc/vintf/manifest/vendor.qti.hardware.display.allocator-service.xml"],
    vendor: true,
    prefer: true,
}

cc_prebuilt_library_shared {
    name: "libsdmcore",
    srcs: ["lib64/libsdmcore.so"],
    compile_multilib: "64",
    vendor: true,
    prefer: true,
}

cc_prebuilt_library_shared {
    name: "libgralloccore",
    srcs: ["lib64/libgralloccore.so"],
    compile_multilib: "64",
    vendor: true,
    prefer: true,
}

cc_prebuilt_library_shared {
    name: "libgrallocutils",
    srcs: ["lib64/libgrallocutils.so"],
    compile_multilib: "64",
    vendor: true,
    prefer: true,
}

cc_prebuilt_library_shared {
    name: "libdisplaydebug",
    srcs: ["lib64/libdisplaydebug.so"],
    compile_multilib: "64",
    vendor: true,
    prefer: true,
}

cc_prebuilt_library_shared {
    name: "libdrmutils",
    srcs: ["lib64/libdrmutils.so"],
    compile_multilib: "64",
    vendor: true,
    prefer: true,
}

cc_prebuilt_library_shared {
    name: "libsdedrm",
    srcs: ["lib64/libsdedrm.so"],
    compile_multilib: "64",
    vendor: true,
    prefer: true,
}

cc_prebuilt_library_shared {
    name: "libgpu_tonemapper",
    srcs: ["lib64/libgpu_tonemapper.so"],
    compile_multilib: "64",
    vendor: true,
    prefer: true,
}

cc_prebuilt_library_shared {
    name: "libhistogram",
    srcs: ["lib64/libhistogram.so"],
    compile_multilib: "64",
    vendor: true,
    prefer: true,
}

cc_prebuilt_library_shared {
    name: "libqservice",
    srcs: ["lib64/libqservice.so"],
    compile_multilib: "64",
    vendor: true,
    prefer: true,
}

cc_prebuilt_library_shared {
    name: "vendor.qti.hardware.display.composer@3.0.vendor",
    stem: "vendor.qti.hardware.display.composer@3.0",
    srcs: ["lib64/vendor.qti.hardware.display.composer@3.0.so"],
    compile_multilib: "64",
    vendor: true,
    prefer: true,
}
```

---

## 5. Manifest & Device Integration Guide

### A. Manifest Overrides (`.repo/local_manifests/rog5s.xml`)
```xml
<!-- Replace default CAF display HAL with stock OEM prebuilts repo -->
<remove-project name="LineageOS/android_hardware_qcom-caf_sm8350_display" />
<project path="hardware/qcom-caf/sm8350/display" name="your-username/android_hardware_qcom-caf_sm8350_display" remote="github" revision="lineage-20.0" />
```

### B. Device Tree Inclusions (`device/asus/rog5s/device.mk`)
```makefile
# Inherit display prebuilts directly
$(call inherit-product, hardware/qcom-caf/sm8350/display/display-product.mk)
```
