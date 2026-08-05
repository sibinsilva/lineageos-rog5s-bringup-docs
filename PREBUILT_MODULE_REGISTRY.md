# 📋 Prebuilt Module Registry & Build Pre-Check Protocol

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Objective**: Maintain a strict 3-way mapping for all prebuilt replacements to completely eliminate Kati/Soong build iteration overhead.

---

## 🗺️ 3-Way Prebuilt Mapping Registry

Whenever replacing a source module with a stock prebuilt, all **3 locations** must be updated simultaneously **before** running `m vendorimage`:

| Module Name | 1. Soong Module (`Android.bp`) | 2. `PRODUCT_PACKAGES` (`device.mk` / `display-product.mk`) | 3. Copy Rule (`rog5s-vendor.mk`) |
| :--- | :--- | :--- | :--- |
| `composer-service` | `hardware/qcom-caf/sm8350/display/composer/Android.bp` (`enabled: false`) | `device/asus/rog5s/device.mk` (Comment out) | Added to `PRODUCT_COPY_FILES` |
| `libsdmcore` | `hardware/qcom-caf/sm8350/display/sdm/libs/core/Android.bp` (`enabled: false`) | `device/asus/rog5s/device.mk` (Comment out) | Added to `PRODUCT_COPY_FILES` |
| `allocator-service` | `hardware/qcom-caf/sm8350/display/gralloc/Android.bp` (`enabled: false`) | `device/asus/rog5s/device.mk` (Comment out) | Added to `PRODUCT_COPY_FILES` |
| `gralloc.default` | AOSP stub auto-built; **override via Soong `cc_prebuilt_library_shared` in `vendor/asus/rog5s/Android.bp`** | ⚠️ **Do NOT add to PRODUCT_COPY_FILES** — conflicts with `base_vendor.mk` | Soong prebuilt module (not copy rule) |
| `libgrallocutils` | `hardware/qcom-caf/sm8350/display/gralloc/Android.bp` (`enabled: false`) | N/A | Added to `PRODUCT_COPY_FILES` |
| `libgralloccore` | `hardware/qcom-caf/sm8350/display/gralloc/Android.bp` (`enabled: false`) | N/A | Added to `PRODUCT_COPY_FILES` |
| `mapper@3.0-impl` | `hardware/qcom-caf/sm8350/display/gralloc/Android.bp` (`enabled: false`) | `device/asus/rog5s/device.mk` (Comment out) | N/A |
| `mapper@4.0-impl` | `hardware/qcom-caf/sm8350/display/gralloc/Android.bp` (`enabled: false`) | `device/asus/rog5s/device.mk` (Comment out) | Added to `PRODUCT_COPY_FILES` |
| `libgpu_tonemapper` | `hardware/qcom-caf/sm8350/display/gpu_tonemapper/Android.bp` (`enabled: false`) | N/A | N/A |

---

## ⚠️ Conflict Rules

> [!WARNING]
> **`gralloc.default` MUST NOT be added to `PRODUCT_COPY_FILES`.**
> `build/make/target/product/base_vendor.mk` line 54 always adds `gralloc.default` to `PRODUCT_PACKAGES`.
> Using `PRODUCT_COPY_FILES` for the same destination path causes Kati error:
> `overriding commands for target 'vendor/lib64/hw/gralloc.default.so'`
>
> **Correct approach**: Create a `cc_prebuilt_library_shared` Soong module named `gralloc.default` in `vendor/asus/rog5s/Android.bp`.
> The module **MUST** include `overrides: ["gralloc.default"]` — without it, Soong + Kati both define
> the same module name and Kati errors: `MODULE.TARGET.SHARED_LIBRARIES.gralloc.default already defined`.
> With `overrides`, Soong suppresses the Android.mk source module cleanly.


---

## 🔒 Mandatory Pre-Build Check Protocol

Before running any `m vendorimage` build command, execute the automated pre-check script to verify:
1. `enabled: false,` is present in `Android.bp` for all targets and dependent internal modules.
2. The module name is commented out in `device.mk` `PRODUCT_PACKAGES`.
3. `PRODUCT_COPY_FILES` in `rog5s-vendor.mk` points to a valid stock binary path.
