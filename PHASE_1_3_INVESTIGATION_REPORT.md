# Boot Failure Investigation: Phases 1–3

## Current Status
* **Device:** ASUS ROG Phone 5S (SM8350 / Snapdragon 888+)
* **Target:** LineageOS 20 (Android 13) | Boot Header Version 3 | GKI
* **Behavior:** Bootloader accepts images -> ASUS splash appears -> Hangs for ~7-8 seconds -> Display turns black -> Device freezes permanently. No ADB, no boot animation, no surviving `pstore`/`ramoops`.
* **Previously Ruled Out:** Custom `dtbo`, `vbmeta`, AVB rejection, missing `fstab.default`. The failure is currently isolated to `boot.img` and/or `vendor_boot.img`.

---

## Phase 1 – Isolate boot.img vs vendor_boot.img (Action Required)

*Important Note: Because of Linux kernel module `vermagic` enforcement, mixing a custom `boot.img` with a stock `vendor_boot.img` will cause module loading to fail (specifically `msm_drm.ko`). This means **both Test A and Test B will almost certainly result in a black screen** because the display driver will be rejected by the kernel. However, if the device reaches ADB, auto-reboots, or changes its crash timing, it still provides vital clues.*

### Test A – Kernel Isolation
* **Flash:** Custom `boot.img` + Stock ASUS `.200` `vendor_boot.img`, `vendor.img`, `dtbo.img`, `vbmeta.img`.
* **Goal:** Determine whether our custom kernel can boot when using ASUS's known-good DTB, vendor ramdisk, and bootconfig.

### Test B – Vendor Boot Isolation
* **Flash:** Stock ASUS `.200` `boot.img` + Custom `vendor_boot.img` + Stock ASUS `.200` `vendor.img`, `dtbo.img`, `vbmeta.img`.
* **Goal:** Determine whether `vendor_boot.img` alone reproduces the hardware initialization failure.

---

## Phase 2 – Inspect the OEM DTB (Completed)

Decompilation of the raw binary of the stock ASUS DTB payload reveals exactly why the generated payload is significantly smaller than stock:

* **Structure:** It is **not** a single DTB. It is a concatenated image containing **4 separate Device Tree Blobs** (identified by 4 distinct FDT magic headers `d0 0d fe ed`).
* **Format:** Standard FDT blobs (not QCDT).
* **Hardware Variants Present:** ASUS concatenated the hardware definitions for three different silicon steppings of the Snapdragon 888 SoC into a single blob. The bootloader scans this blob and passes the one that exactly matches the physical phone's CPU ID:
  * **DTB 0:** `model = "Qualcomm Technologies, Inc. Lahaina V2.1 SoC" | qcom,msm-id = <0x19f 0x20001>`
  * **DTB 1:** `model = "Qualcomm Technologies, Inc. Lahaina V2 SoC" | qcom,msm-id = <0x19f 0x20000>`
  * **DTB 2:** `model = "Qualcomm Technologies, Inc. lahaina v1 SoC" | qcom,msm-id = <0x19f 0x10000>`
* **The Discrepancy:** The LineageOS kernel build process only generated **one** DTB (`asus-lahaina.dtb` - 410 KB), targeting only the V2 SoC. The ASUS OEM payload (1.43 MB) contains the definitions for *all* steppings.

---

## Phase 3 – Compare vendor_boot Images (Completed)

Images were unpacked using AOSP's `unpack_bootimg.py` and the ramdisks were extracted.

### The Structural Matches (No Issue)
* **Boot header version:** `3` (Matches perfectly)
* **Page size:** `0x1000` (Matches perfectly)
* **Kernel load address:** `0x00008000` (Matches perfectly)
* **Ramdisk load address:** `0x01000000` (Matches perfectly)

### The Critical Discrepancies
1. **DTB Payload Size:** 
   * **Stock:** 1,429,937 bytes
   * **Custom:** 410,902 bytes
2. **Vendor Ramdisk Size:**
   * **Stock:** 1,893,638 bytes (GZIP Compressed)
   * **Custom:** 3,239,435 bytes (GZIP Compressed)
   * **Cause of Size Difference:** Decompressing both ramdisks reveals that the custom Lineage ramdisk contains a `system/` directory (5.4 MB uncompressed) containing `e2fsck`, `fsck.f2fs`, `linker64`, and `libc.so`. This is because we set `BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true`, which packages recovery binaries into `vendor_boot`. Stock ASUS firmware puts recovery in `boot.img`, so its `vendor_boot` lacks these files. This discrepancy is completely normal for our build architecture and is not an error.
3. **Kernel Cmdline:**
   * **Stock** has `loop.max_part=7` listed twice, and uses `buildvariant=user`.
   * **Custom** has `buildvariant=userdebug` listed twice. (These are cosmetic and will not cause an early boot panic).

---

## Phase 4 – DTB Replacement (In Progress)

Based on the evidence from Phase 2, the `BoardConfig.mk` flags have been audited and corrected:

1. Permanently removed `BOARD_INCLUDE_DTB_IN_BOOTIMG := true`. Setting this flag while using V3 headers creates an architectural conflict, causing the build system to misplace the DTB payload.
2. Injected `BOARD_PREBUILT_DTBIMAGE_DIR` into the board config, pointing it to the exact 1.43 MB OEM concatenated DTB blob. 
3. A clean rebuild of `vendor_boot.img` is currently in progress to package this OEM blob into the custom image.

---

## Evidence-Based Conclusion

While DTB discrepancy remains the leading hypothesis, we must refine our understanding based on the latest data. 

Decompiling our custom 410 KB DTB revealed that it perfectly matched the hardware revision of the test device (`model = "Qualcomm Technologies, Inc. Lahaina V2.1 SoC"` and `qcom,msm-id = <0x19f 0x20001>`). Therefore, the bootloader **did not fail** to find a matching DTB, and the lack of the other three SoC steppings in our payload does not explain this specific failure.

However, a critical mismatch remains: the single OEM V2.1 DTB inside the stock payload is **480 KB**, while our custom V2.1 DTB is only **410 KB**. 

**Current Hypothesis:** 
The generated DTB matches the correct SoC stepping, so the bootloader is selecting the appropriate DTB. However, the generated DTB remains approximately 70 KB smaller than the OEM V2.1 DTB, indicating that OEM-specific hardware definitions are absent. It is therefore plausible that the missing DTB content causes a failure during early kernel hardware initialization or early driver probing before useful logging becomes available. This remains a hypothesis until validated by additional testing.

Replacing the custom DTB with the prebuilt 1.43 MB OEM DTB payload will definitively test this hypothesis by guaranteeing a 100% accurate hardware map during early initialization.
