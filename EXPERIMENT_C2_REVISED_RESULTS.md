# 🧪 Experiment C2 (Revised) — Full Graphics Allocation Stack Prebuilts

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D`)  
**Build Status**: **SUCCESSFUL**  
**Download Link**: https://temp.sh/MDcBs/vendor.img  
**SHA-256 Checksum**: `6782874b591dc9459402e4ccb5f395cb061b1fc4afbc44caa111976e641ecaa2`

---

## 📊 8-Point Prebuilt Integrity Audit Results

All 8 graphics allocation components were verified byte-for-byte against the stock ASUS firmware dump prior to packaging:

| Binary Component | Stock SHA-256 | Built SHA-256 | Build ID | Audit Result |
| :--- | :--- | :--- | :--- | :---: |
| `vendor.qti.hardware.display.composer-service` | `4d54d022...` | `4d54d022...` | `55901499...` | ✅ MATCH |
| `libsdmcore.so` | `3dc47a2c...` | `3dc47a2c...` | `1cf71e32...` | ✅ MATCH |
| `vendor.qti.hardware.display.allocator-service` | `6ac4ebb7...` | `6ac4ebb7...` | `93abf263...` | ✅ MATCH |
| `gralloc.default.so` | `4f1b1a86...` | `4f1b1a86...` | `74a1cda1...` | ✅ MATCH |
| `libgrallocutils.so` | `ac8c6d31...` | `ac8c6d31...` | `51a66cf4...` | ✅ MATCH |
| `libgralloccore.so` | `a3ccf973...` | `a3ccf973...` | `993aed99...` | ✅ MATCH |
| `android.hardware.graphics.mapper@3.0-impl-qti-display.so` | `ab24cb76...` | `ab24cb76...` | `6d1b99f2...` | ✅ MATCH |
| `android.hardware.graphics.mapper@4.0-impl-qti-display.so` | `8ed8757f...` | `8ed8757f...` | `77115347...` | ✅ MATCH |

---

## ⚡ Flashing Instructions

```bash
# 1. Reboot into userspace fastbootd
adb reboot fastboot

# 2. Verify fastbootd (userspace fastboot) is active
fastboot getvar is-userspace
# Must return: is-userspace: yes

# 3. Flash the verified vendor partition
fastboot flash vendor vendor.img

# 4. Reboot device
fastboot reboot
```

---

## 🔍 Logcat Monitoring Focus

Upon boot, collect logcat:
```bash
adb logcat -b all > logcat_expC2_revised.txt
```

Watch for:
1. `vendor.qti.hardware.display.allocator-service` startup.
2. `eglInitialize()` progress inside SurfaceFlinger / RenderEngine.
3. Launch of `BootAnimation`.
