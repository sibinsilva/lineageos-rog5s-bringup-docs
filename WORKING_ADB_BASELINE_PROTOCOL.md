# 🛡️ WORKING ADB BASELINE PROTOCOL & RECIPE (ASUS ROG Phone 5s - sake)

> [!IMPORTANT]
> **Status:** ACTIVE WORKING BASELINE  
> **Device State:** Boots past ROG logo to Black Screen state with **ADB 100% Active & Logging**.  
> **Purpose:** Primary rollback checkpoint for display bringup and boot animation debugging.

---

## 📦 1. Artifact & Download Checkpoint

| Attribute | Details |
|:---|:---|
| **Direct Download URL** | [https://temp.sh/CLoOp/vendor_final_100pct_stock_oem.zip](https://temp.sh/CLoOp/vendor_final_100pct_stock_oem.zip) |
| **Local Staging Path** | `/tmp/vendor_final_100pct_stock_oem.zip` |
| **Sparse Vendor Image** | `/tmp/vendor_final_100pct_stock_oem.img` (1.2 GB) |
| **Zip MD5 Checksum** | `9b79b3cbc974fa7671e0231bc40f3401` |
| **Target Architecture** | Qualcomm SM8350 (Lahaina / sake / ROG Phone 5s) |

---

## 📋 2. Complete Step-by-Step Creation Recipe

### Step 1: Base Tree & Repository Setup
1. **Display Hardware Tree (`hardware/qcom-caf/sm8350/display`)**:
   - Sourced from Commit `37b209b` (`sm8350: display: Define vendor.qti.hardware.display.composer@3.0 as stock prebuilt`).
2. **Device Tree (`device/asus/rog5s`)**:
   - `device.mk` configured for active USB debugging:
     ```makefile
     PRODUCT_PROPERTY_OVERRIDES += \
         persist.sys.usb.config=adb \
         ro.adb.secure=0
     ```
3. **Vendor Tree (`vendor/asus/rog5s`)**:
   - `rog5s-vendor.mk` updated to avoid Soong duplication errors by commenting out `iris-service`:
     ```makefile
     # vendor/asus/rog5s/proprietary/vendor/bin/hw/vendor.pixelworks.hardware.display.iris-service
     # vendor/asus/rog5s/proprietary/vendor/etc/init/vendor.pixelworks.hardware.display.iris-service.rc
     ```

### Step 2: Source Compilation (`m vendorimage`)
- Execute `m vendorimage` using `ccache`:
  ```bash
  export USE_CCACHE=1
  export CCACHE_EXEC=/usr/bin/ccache
  export CCACHE_DIR=/home/sibindev9746_gmail_com/.ccache
  source build/envsetup.sh && lunch lineage_rog5s-userdebug
  m vendorimage
  ```

### Step 3: Image Post-Processing & Prebuilt Injection
Because Soong overrides generic display libraries (`libdrm.so` and `composer@3.0.so`), post-processing is executed directly on the built `vendor.img`:

1. **Unsparse Build Output**:
   ```bash
   simg2img out/target/product/rog5s/vendor.img /tmp/vendor_final_raw.img
   ```
2. **Mount Raw Image**:
   ```bash
   mkdir -p /tmp/mnt_vendor
   sudo mount -o loop /tmp/vendor_final_raw.img /tmp/mnt_vendor
   ```
3. **Inject Stock OEM Prebuilts**:
   ```bash
   STOCK="/home/sibindev9746_gmail_com/rog5s_stock_firmware/dump/vendor"
   sudo cp -v "$STOCK/lib64/vendor.qti.hardware.display.composer@3.0.so" /tmp/mnt_vendor/lib64/
   sudo cp -v "$STOCK/lib64/libdrm.so" /tmp/mnt_vendor/lib64/
   ```
4. **Unmount & Convert to Sparse Image**:
   ```bash
   sudo umount /tmp/mnt_vendor
   img2simg /tmp/vendor_final_raw.img /tmp/vendor_final_100pct_stock_oem.img
   ```

---

## 🛡️ 3. 100% Display Binary MD5 Audit Matrix

Every single display HAL binary inside `vendor_final_100pct_stock_oem.img` matches the stock ASUS firmware dump:

| Binary Path in Partition | Stock Firmware MD5 | Image MD5 | Status |
|:---|:---:|:---:|:---:|
| `bin/hw/vendor.qti.hardware.display.composer-service` | `cc9bb94523a6eedf73d8d21f14ef9d13` | `cc9bb94523a6eedf73d8d21f14ef9d13` | **PASS ✅** |
| `bin/hw/vendor.qti.hardware.display.allocator-service` | `3362675cb327de7c511e7dc915454d7c` | `3362675cb327de7c511e7dc915454d7c` | **PASS ✅** |
| `bin/hw/vendor.pixelworks.hardware.display.iris-service` | `f205ca18adfc9e9f67647634f25bb1fc` | `f205ca18adfc9e9f67647634f25bb1fc` | **PASS ✅** |
| `lib64/vendor.qti.hardware.display.composer@3.0.so` | `a9fabeb3a9b8f9f60532430676aa9675` | `a9fabeb3a9b8f9f60532430676aa9675` | **PASS ✅** |
| `lib64/libsdmcore.so` | `8f65ec8a4d63f34eb53107b191e4c88f` | `8f65ec8a4d63f34eb53107b191e4c88f` | **PASS ✅** |
| `lib64/libsdedrm.so` | `66170c20238d428807176f9bfeb2f6cc` | `66170c20238d428807176f9bfeb2f6cc` | **PASS ✅** |
| `lib64/libgralloccore.so` | `a779c3246beddf475e56f87827de299b` | `a779c3246beddf475e56f87827de299b` | **PASS ✅** |
| `lib64/libgrallocutils.so` | `4557c17e5f07c94528bbd5ef21951812` | `4557c17e5f07c94528bbd5ef21951812` | **PASS ✅** |
| `lib64/libdrm.so` (Stock OEM) | `a7a227e957ab380a276f11a602dd70f6` | `a7a227e957ab380a276f11a602dd70f6` | **PASS ✅** |
| `lib64/libdrmutils.so` | `cca2bac6feb9ffd887dc54181bb8cbb8` | `cca2bac6feb9ffd887dc54181bb8cbb8` | **PASS ✅** |
| `lib64/libgpu_tonemapper.so` | `aeda2624f7e586d6d44325d2c77c83b0` | `aeda2624f7e586d6d44325d2c77c83b0` | **PASS ✅** |
| `lib64/libhistogram.so` | `228db3cdf75c664796de2c375922b4e1` | `228db3cdf75c664796de2c375922b4e1` | **PASS ✅** |
| `lib64/libqservice.so` | `7f8f7b55dbbe5e356bd6192fd646b03f` | `7f8f7b55dbbe5e356bd6192fd646b03f` | **PASS ✅** |
| `lib64/libdisplaydebug.so` | `d516d36447df5df347a0ae0606437f48` | `d516d36447df5df347a0ae0606437f48` | **PASS ✅** |

---

## 🔄 4. Rollback & Recovery Instructions

If any future change breaks ADB or display logging:

```powershell
# 1. Download and extract vendor_final_100pct_stock_oem.img
# 2. Reboot phone to Fastboot mode
adb reboot bootloader

# 3. Flash to Slot B (and Slot A)
fastboot set_active b
fastboot flash vendor_b vendor_final_100pct_stock_oem.img
fastboot flash vendor_a vendor_final_100pct_stock_oem.img

# 4. Reboot to restore working ADB state
fastboot reboot
```
