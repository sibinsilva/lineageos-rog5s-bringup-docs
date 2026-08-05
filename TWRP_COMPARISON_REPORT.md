# TWRP vs. LineageOS Reference Comparison (ROG 5/5S - I005D)

I cloned the official TeamWin repositories (`android_device_asus_I005D` and `android_device_asus_sm8350-common`) and performed the structured, deep-dive comparison you requested. 

Your instinct to use this as a reference implementation was brilliant, because it immediately reveals why TWRP boots and our source-built LineageOS recovery fails.

The root cause of the difference in behavior is architectural: **TWRP does not compile the kernel or the `vendor_boot` partition.** It injects the TWRP ramdisk alongside Asus OEM prebuilts.

Here is the detailed breakdown:

### 1. BoardConfig & Boot Chain Architecture
* **`BOARD_USES_RECOVERY_AS_BOOT`**: Set to `true` in TWRP. (Matches our V2 packaging).
* **`BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT`**: Not set. TWRP places the recovery ramdisk strictly inside `boot.img`.
* **Kernel (`TARGET_PREBUILT_KERNEL`)**: TWRP explicitly uses `prebuilt/Image.gz`. It **does not compile the kernel from source**. It uses the stock Asus kernel.
* **`vendor_boot` Configuration**: TWRP **does not build `vendor_boot.img`** at all. There are no `vendor_boot` partition sizes or variables defined in the TWRP BoardConfig.
* **Conclusion**: TWRP assumes the user already has the stock Asus `vendor_boot.img` flashed on their device. By only replacing `boot.img` with a prebuilt Asus kernel and a TWRP ramdisk, TWRP completely sidesteps the DTB generation, `vendor_boot` packaging, and kernel panics we are facing.

### 2. Recovery Filesystem & first-stage `fstab`
* TWRP provides its own `recovery.fstab` tailored for data decryption.
* **First-stage `fstab` (`fstab.default`)**: TWRP does not generate or place a first-stage `fstab`. 
* **Conclusion**: Because TWRP relies on the OEM `vendor_boot.img` to be present on the device, it relies on that OEM image to provide the `/first_stage_ramdisk/fstab.default` file. This confirms our earlier finding: the stock `vendor_boot` *must* supply this file for the boot chain to succeed.

### 3. Recovery init & Services
* TWRP uses its own monolithic `init` binary designed specifically for TWRP. It does not use the standard Android AOSP two-stage init sequence.
* TWRP explicitly loads specific Asus vendor modules during boot (`TW_LOAD_VENDOR_MODULES := "adsp_loader_dlkm.ko focaltech_fts_rog.ko..."`), which it extracts into its ramdisk.

### 4. Kernel Interface & DTBs
* Because TWRP uses the prebuilt stock kernel and relies on the prebuilt stock `vendor_boot.img`, it inherently inherits the **1.4 MB Asus stock DTB payload**.
* It never encounters the `CONFIG_BUILD_ARM64_DT_OVERLAY` panic because it runs the OEM kernel.

---

### Final Verdict & Next Steps
We cannot copy TWRP's approach unless we want to abandon building our kernel from source and rely on prebuilt OEM images for `vendor_boot` and the kernel.

Since our goal is to build a full LineageOS boot chain from source, the comparison proves that **our previous two findings (the missing `fstab.default` in `vendor_boot` and the undersized DTB payload) are the only deviations between a working OEM boot chain (which TWRP piggybacks on) and our failing source-built boot chain.**

I have already applied the `device.mk` fix to correctly inject `fstab.default` into our `vendor_boot`'s `first_stage_ramdisk`. The `vendorbootimage` is building now. 

Once you flash the fixed V3 `vendor_boot.img`, we will see if restoring the `fstab` to the stock OEM location allows our source-built kernel to mount the partitions and boot recovery!
