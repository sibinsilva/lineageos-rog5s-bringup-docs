# Runtime Boot Chain Comparison: Stock vs. LineageOS (V2)

Per your request to maintain the controlled experiment and gather more evidence, I unpacked both the stock ASUS `boot.img`/`vendor_boot.img` and our LineageOS V2 images. I fully extracted the CPIO ramdisks to compare the runtime environments.

We found three major discrepancies that are highly likely to cause an early boot panic or infinite hang.

## 1. Kernel Command Line (`cmdline`) & Bootconfig
Header V3 does not utilize a dedicated `bootconfig` payload (it was introduced in V4). All parameters are passed via the `vendor_cmdline`.

**Stock cmdline:**
```text
console=ttyMSM0,115200n8 androidboot.hardware=qcom androidboot.console=ttyMSM0 androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 androidboot.usbcontroller=a600000.dwc3 swiotlb=0 loop.max_part=7 cgroup.memory=nokmem,nosocket pcie_ports=compat loop.max_part=7 iptable_raw.raw_before_defrag=1 ip6table_raw.raw_before_defrag=1 buildvariant=user
```

**LineageOS V2 cmdline:**
```text
console=ttyMSM0,115200n8 androidboot.hardware=qcom androidboot.console=ttyMSM0 androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 androidboot.usbcontroller=a600000.dwc3 swiotlb=0 loop.max_part=7 cgroup.memory=nokmem,nosocket pcie_ports=compat iptable_raw.raw_before_defrag=1 ip6table_raw.raw_before_defrag=1 buildvariant=userdebug buildvariant=userdebug
```
**Conclusion:** The command lines are functionally identical. The only minor delta is `buildvariant=userdebug` instead of `user`, which is expected and benign.

---

## 2. First-Stage Init & Mount Configuration (`fstab`)
This is a **critical failure point**. During early boot, the kernel mounts the `vendor_boot` ramdisk and launches first-stage `init`. That `init` instance *must* find an `fstab` to know how to mount the logical partitions (like `system`, `vendor`, `data`) from the `super` container.

**Stock `vendor_boot` Ramdisk Contents:**
```text
/first_stage_ramdisk/fstab.default   (6.0K)
/first_stage_ramdisk/fstab.emmc      (5.4K)
```

**LineageOS V2 `vendor_boot` Ramdisk Contents:**
```text
/first_stage_ramdisk/system/
```
**Conclusion:** Our V2 build **completely omitted the first-stage fstabs** from the `vendor_boot` ramdisk. When `init` starts in our build, it has no `fstab.default` to read. It cannot mount `/system` or `/vendor`, so it panics and halts immediately. This alone perfectly explains the black screen a few seconds after the ASUS logo.

---

## 3. DTB Selection and Sizing
There is a massive size discrepancy in the appended Device Tree Blob (DTB) payload located in `vendor_boot.img`.

* **Stock `dtb` payload size:** `1.4 MB` (1,429,937 bytes)
* **LineageOS V2 `dtb` payload size:** `400 KB` (410,902 bytes)

**Conclusion:** The stock ASUS `vendor_boot` image is appending a massively larger DTB (likely concatenating multiple variants or containing huge custom ASUS hardware nodes). Our 400 KB payload suggests we are either missing critical OEM DTBs, or we are only generating a generic Qualcomm reference DTB that lacks the ASUS display panel / hardware definitions. This is the second major vector for an early boot panic (failing to probe hardware).

---

## Next Steps
You were absolutely right to demand this evidence before blindly toggling the DT overlay flag! 

We now have two definitive runtime blockers that have nothing to do with `CONFIG_BUILD_ARM64_DT_OVERLAY`:
1. The missing `fstab.default` in `vendor_boot`.
2. The drastically undersized `dtb` payload.

Before we touch the kernel configuration, we must fix the build system to inject the `fstab` into `vendor_boot`, and investigate the prebuilt DTBs.
