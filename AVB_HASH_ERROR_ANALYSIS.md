# Root Cause Analysis: Qualcomm ABL AVB Hash Verification Failure

> **Source Log**: Extracted from raw hardware `/dev/block/by-name/logfs`  
> **Bootloader**: Qualcomm ABL (Android Boot Loader)  
> **Fault Module**: `avb_slot_verify.c:247`

---

## 1. Qualcomm ABL Bootloader Log Lines

```text
Booting from slot (_a)
Booting Into Mission Mode
avb_slot_verify.c:728: ERROR: vbmeta_system_a: Image rollback index is less than the stored rollback index.
[ABL] Allow skip AVB_SLOT_VERIFY_RESULT_ERROR_ROLLBACK_INDEX
avb_slot_verify.c:247: ERROR: boot_a: Hash of data does not match digest in descriptor.
avb_slot_verify.c:247: ERROR: vendor_boot_a: Hash of data does not match digest in descriptor.
...
Err: line:1733 FindBootableSlot() status: Load Error
Err: line:1679 LoadImageAndAuth() status: Load Error
LoadImageAndAuth failed: Load Error
```

---

## 2. Root Cause Mechanism

1. **AVB Hash Descriptor Mismatch**:
   - Qualcomm ABL reads `boot.img` and `vendor_boot.img` from flash into RAM.
   - ABL computes the SHA-256 hash of the binary images and compares them against the digest stored in the AVB (Android Verified Boot) descriptor / vbmeta footer.
2. **Boot Abort**:
   - Because `boot_a` and `vendor_boot_a` fail the digest match (`Hash of data does not match digest in descriptor`), ABL fails authentication with `LoadImageAndAuth failed: Load Error`.
3. **The 4-Reboot Loop**:
   - ABL aborts loading the kernel, retries 4 times, marks Slot A unbootable, and drops into Fastboot.

---

## 3. Resolution Plan

1. **Pass `--flags 3` to AVB `vbmeta`**:
   Add `--flags 3` (`AVB_VBMETA_IMAGE_FLAGS_HASHTREE_DISABLED | AVB_VBMETA_IMAGE_FLAGS_VERIFICATION_DISABLED`) to `BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS` in `BoardConfig.mk`. This instructs ABL to skip digest verification on `boot` and `vendor_boot`.
2. **Flash Disabled `vbmeta`**:
   Flash a `vbmeta.img` generated with verification disabled:
   ```powershell
   fastboot flash vbmeta --disable-verity --disable-verification vbmeta.img
   ```
