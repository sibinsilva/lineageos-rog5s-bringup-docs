# 🔍 Actual Blob Presence & Verification Report

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `rog5s`)  
**Date**: August 11, 2026

---

## 🎯 Empirical Verification Findings

1. **Blob File Existence**:
   * [`vendor/asus/rog5s/proprietary/vendor/lib64/libsdmextension.so`](file:///mnt/android-build/vendor/asus/rog5s/proprietary/vendor/lib64/libsdmextension.so) **EXISTS** (64-bit ELF shared object).
   * [`vendor/asus/rog5s/proprietary/vendor/bin/hw/vendor.display.color@1.0-service`](file:///mnt/android-build/vendor/asus/rog5s/proprietary/vendor/bin/hw/vendor.display.color@1.0-service) **EXISTS**.
   * [`vendor/asus/rog5s/proprietary/vendor/lib64/libsdm-color.so`](file:///mnt/android-build/vendor/asus/rog5s/proprietary/vendor/lib64/libsdm-color.so) **EXISTS**.

2. **SHA1 Checksum Comparison**:
   * Checksum in [`proprietary-files.txt`](file:///mnt/android-build/device/asus/rog5-common/proprietary-files.txt#L738) (spacewar comment): `6d7a088d75bf540698171e7d850d95644a9b9bc0`
   * Checksum of actual file in [`vendor/asus/rog5s`](file:///mnt/android-build/vendor/asus/rog5s/proprietary/vendor/lib64/libsdmextension.so): `98d3589dc633906a3c2206d2a9d51126f8a98301`
   * **Conclusion**: The comment `# Display - from spacewar` was a legacy label in `proprietary-files.txt`, but the actual binary present in `vendor/asus/rog5s` **is the real stock ASUS ROG 5S binary** (SHA1 `98d3589...`).

3. **Function Symbol Breakdown**:
   * Inspecting binary symbols in `libsdmextension.so` proves it implements:
     `sdm::ExtensionImpl::CreateResourceExtn(const sdm::HWResourceInfo&, sdm::BufferAllocator*, sdm::ResourceInterface**)`
   * The ABI mismatch occurs between the stock ASUS `libsdmextension.so` (compiled against ASUS's internal SM8350 headers) and open-source CAF `libsdmcore.so` (compiled against LineageOS SM8350 CAF headers with 24-byte `tap_points` alignment shift).
