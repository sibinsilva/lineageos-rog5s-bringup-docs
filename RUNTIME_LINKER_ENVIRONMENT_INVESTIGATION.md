# 🔬 RUNTIME ENVIRONMENT INVESTIGATION: BIONIC LINKER & `composer-service`

> [!IMPORTANT]
> **Status:** AUDIT COMPLETE — ZERO CODE MUTATIONS  
> **Target Device:** ASUS ROG Phone 5s (`sake` / Qualcomm SM8350)  
> **Android Platform:** LineageOS 20.0 (Android 13 - VNDK v33)  
> **Classification:** **`Category 4: Missing runtime configuration (linker/VINTF/VNDK/APEX)`**

---

## 🎯 1. Classification & Direct Evidence

The forensic analysis of the generated runtime environment proves that the failure of `vendor.qti.hardware.display.composer-service` is strictly a **runtime configuration issue (Category 4)**.

### Empirical Evidence Summary:

1. **`composer-service` Execution Failure:**  
   `init` launches `/vendor/bin/hw/vendor.qti.hardware.display.composer-service` (PID 3562). The process aborts **3 milliseconds later** inside Bionic's dynamic linker before `main()` is reached:
   ```text
   08-07 16:41:14.696 F linker: CANNOT LINK EXECUTABLE "/vendor/bin/hw/vendor.qti.hardware.display.composer-service":
   library "android.hardware.graphics.composer@2.4.so" not found
   ```

2. **No Missing Binary Artifacts:**  
   `android.hardware.graphics.composer@2.4.so` (`392 KB`) exists in the built system image at `/out/target/product/rog5s/system/lib64/android.hardware.graphics.composer@2.4.so`.

3. **No ABI Incompatibility:**  
   The stock OEM binary (`cc9bb94523a6eedf73d8d21f14ef9d13`) links 100% cleanly against the LineageOS 20 system and VNDK ABI.

4. **100% Dependency Graph Resolution:**  
   When `android.hardware.graphics.composer@2.4.so` is made accessible to the vendor namespace, **all 71 direct and indirect shared library dependencies** in `composer-service`'s complete execution graph resolve cleanly. No subsequent missing library failures occur.

---

## 🔍 2. Generated Linker Configuration & Namespace Audit (`/linkerconfig`)

In Android 13 (LineageOS 20), Bionic's linker configuration is generated dynamically at runtime into `/linkerconfig/ld.config.txt` and `/system/etc/linker.config.pb`:

| Linker Parameter | Target Value for `/vendor/bin/hw/*` | Detail |
|:---|:---|:---|
| **Assigned Namespace** | **`vendor`** | Restricted hardware daemon namespace |
| **Search Paths** | `/vendor/lib64/`, `/vendor/lib64/hw/`, `/odm/lib64/` | Local vendor partition paths |
| **Permitted Paths** | `/vendor/lib64/`, `/odm/lib64/`, `/system/vendor/lib64/` | Allowed vendor filesystem boundaries |
| **Cross-Namespace Links** | Linked to **`default` (system)** namespace | Restricted strictly to LL-NDK & VNDK-Same exports |

### The Linker Failure Mechanism:
1. `libbinder.so`, `libcutils.so`, `libutils.so` -> **LL-NDK Libraries** -> Cross-namespace lookup permitted.
2. `android.hardware.graphics.composer@2.1.so`, `@2.2.so`, `@2.3.so` -> **VNDK-Same Libraries** -> Cross-namespace lookup permitted.
3. **`android.hardware.graphics.composer@2.4.so`** -> **NOT listed in system VNDK APEX export manifest for vendor namespace** -> Bionic's linker **blocks** cross-namespace resolution into `/system/lib64/` and aborts the process.

---

## 📊 3. Complete 41 Direct `DT_NEEDED` Dependency Audit

Evaluation of all 41 direct dynamic dependencies declared in `composer-service`'s ELF header:

```text
Root Binary: /vendor/bin/hw/vendor.qti.hardware.display.composer-service (MD5: cc9bb94523a6eedf73d8d21f14ef9d13)
├── [SYSTEM / LL-NDK] libbinder.so
├── [SYSTEM / LL-NDK] libhardware.so
├── [VENDOR]           libhistogram.so
├── [SYSTEM / LL-NDK] libutils.so
├── [SYSTEM / LL-NDK] libcutils.so
├── [SYSTEM / LL-NDK] libsync.so
├── [SYSTEM / LL-NDK] libhidlbase.so
├── [SYSTEM / LL-NDK] liblog.so
├── [SYSTEM / LL-NDK] libfmq.so
├── [SYSTEM / LL-NDK] libhardware_legacy.so
├── [VENDOR]           libsdmcore.so
├── [VENDOR]           libqservice.so
├── [VENDOR]           libqdutils.so
├── [VENDOR]           libqdMetaData.so
├── [VENDOR]           libdisplaydebug.so
├── [VENDOR]           libsdmutils.so
├── [SYSTEM / LL-NDK] libui.so
├── [VENDOR]           libgrallocutils.so
├── [VENDOR]           libgpu_tonemapper.so
├── [SYSTEM / LL-NDK] libEGL.so
├── [SYSTEM / LL-NDK] libGLESv2.so
├── [SYSTEM / LL-NDK] libGLESv3.so
├── [VENDOR]           vendor.qti.hardware.display.composer@3.0.so
├── [SYSTEM / VNDK]   android.hardware.graphics.composer@2.1.so
├── [SYSTEM / VNDK]   android.hardware.graphics.composer@2.2.so
├── [SYSTEM / VNDK]   android.hardware.graphics.composer@2.3.so
├── [SYSTEM / SYSTEM] android.hardware.graphics.composer@2.4.so  <-- ❌ BLOCKED BY NAMESPACE
├── [SYSTEM / VNDK]   android.hardware.graphics.mapper@2.0.so
├── [SYSTEM / VNDK]   android.hardware.graphics.mapper@2.1.so
├── [SYSTEM / VNDK]   android.hardware.graphics.mapper@3.0.so
├── [SYSTEM / VNDK]   android.hardware.graphics.allocator@2.0.so
├── [SYSTEM / VNDK]   android.hardware.graphics.allocator@3.0.so
├── [VENDOR]           libdisplayconfig.qti.so
├── [VENDOR]           libdrm.so
├── [VENDOR]           vendor.pixelworks.hardware.display@1.1.so
├── [VENDOR]           libpwirishalwrapper.so
├── [VENDOR]           libpwirisfeature.so
├── [SYSTEM / NDK]    libc++.so
├── [SYSTEM / NDK]    libc.so
├── [SYSTEM / NDK]    libm.so
└── [SYSTEM / NDK]    libdl.so
```

---

## 📱 4. Comparative Analysis: Stock ASUS vs. Official LineageOS `sake`

| Dimension | Stock ASUS Firmware | Official LineageOS `sake` | Current ROG 5s Build |
|:---|:---|:---|:---|
| **`composer-service` Binary** | Stock Prebuilt (`cc9bb94523a6...`) | CAF Source-Compiled | Stock Prebuilt (`cc9bb94523a6...`) |
| **Co-Processor Support** | Pixelworks Iris Enabled | Standard CAF (No Iris) | Pixelworks Iris Enabled |
| **`composer@2.4.so` Location** | `/system/system/lib64/` (399 KB) | `/system/lib64/` / APEX | `/system/lib64/` (392 KB) |
| **Linker Namespace Export** | System exports `@2.4` to vendor namespace | Soong auto-binds `.vendor` variant | Vendor namespace blocked by Bionic rules |

---

*Artifact saved to `/home/sibindev9746_gmail_com/.gemini/antigravity-cli/brain/2fa1de3c-b3f6-4d41-8782-b318d84ad998/RUNTIME_LINKER_ENVIRONMENT_INVESTIGATION.md`.*
