# Kirisakura Kernel vs. LineageOS Reference Comparison (ROG 5/5S)

I analyzed the `Kirisakura_ANAKIN_ROG5` source directory, focusing on its build scripts (`build_kirisakura.sh`), its packaging scripts (`package_kernel.sh`), and its `AnyKernel3` deployment structure. 

The findings here perfectly mirror what we discovered with TWRP. **Kirisakura succeeds for the exact same architectural reason TWRP succeeds: it completely bypasses `vendor_boot` and DTB flashing, relying on the stock Asus OEM firmware to provide them.**

Here is the detailed breakdown addressing your specific questions:

### 1. DTB Generation and Final DTB Payload
* **Generation**: Kirisakura *does* generate DTBs during its kernel compile (`make kirisakura_defconfig && make`). The compiler successfully spits out `asus-lahaina.dtb` and the overlays.
* **Final Payload (The Catch)**: When Kirisakura runs its `package_kernel.sh` script to build the flashable zip, **it explicitly throws the compiled DTBs away**. It copies only `Image.gz` and a few specific `.ko` modules (like `focaltech_fts_rog2.ko`) into the AnyKernel3 folder.
* **Why the payload is smaller**: Our LineageOS build creates a 400KB payload because it compiles and flashes our own device-specific DTB into the `vendor_boot` partition. Kirisakura's flashable zip does not contain *any* DTB files. When a user flashes Kirisakura, the `anykernel.sh` script specifically targets `/dev/block/bootdevice/by-name/boot` and leaves `vendor_boot` untouched. Therefore, Kirisakura boots against the **stock Asus 1.4 MB DTB payload** that was already present on the device.

### 2. Defconfig Differences Affecting Boot
* Kirisakura builds using `kirisakura_defconfig`. 
* Because Kirisakura boots using the stock Asus `vendor_boot` DTBs, kernel config options like `CONFIG_BUILD_ARM64_DT_OVERLAY` are essentially irrelevant to its packaging success. The compiled kernel simply parses the stock OEM DTBs provided by the bootloader from the untouched `vendor_boot` partition.

### 3. Boot Image Construction and AnyKernel Packaging
* Kirisakura uses standard `AnyKernel3` to unpack the stock `boot.img` on the device, swap out the stock `Image` for its custom compiled `Image.gz`, and repack it.
* It injects a few driver modules (`texfat.ko`, `tntfs.ko`) via Magisk/KernelSU overlays so it doesn't even need to modify the vendor filesystem directly.
* **Crucially, `anykernel.sh` has the `vendor_boot` patching block commented out.** It never touches the partition responsible for first-stage init (`fstab.default`) or the DTB payload.

### 4. ASUS-Specific Kernel Patches Related to Early Boot
* Kirisakura undeniably contains deep kernel patches and optimizations. However, its *early boot* success (getting past the bootloader and mounting partitions) is guaranteed by the fact that it is paired with the untouched Asus OEM `vendor_boot` ramdisk and Asus OEM DTBs. 

---

### Conclusion

Both of the known-working references for the ROG 5 (TWRP and Kirisakura) succeed by acting as "parasites" on the OEM boot chain. They replace only the `boot` partition (or the recovery ramdisk inside it) and rely entirely on the stock `vendor_boot.img` to provide the complex hardware DTB blobs and the crucial `fstab.default` first-stage mount instructions.

Because we are bringing up LineageOS, we are attempting a true "clean room" source build of the entire boot chain—which means we cannot rely on the OEM `vendor_boot`. 

This confirms that our hypothesis is structurally sound: **The missing `fstab.default` in our `vendor_boot` ramdisk is the most critical deviation from the OEM standard.** We are waiting for the current `vendorbootimage` compilation to finish so we can test the fix.
