# Bring-Up Status: ASUS ROG Phone 5S (`ZS676KS` / `sm8350`)

> **Current Phase**: **PRE-FLASH HARDWARE TEST READY**  
> **Kernel Source**: Kirisakura (`ANAKIN_ROG5`) merged tree  
> **Target OS**: LineageOS 20 (`Android 13`)  
> **Compiler**: Clang 14.0.7 with LLVM Integrated Assembler (`LLVM_IAS=1`)  
> **Build Target**: `boot.img` & `vendor_boot.img`  
> **Build Result**: **100% SUCCESS (`0 errors`, `0 warnings`)**

---

## Approved Project Artifacts

All 11 technical bring-up artifacts have been formally reviewed and approved:

1. ✅ [BRINGUP_STATUS.md](file:///home/sibindev9746_gmail_com/.gemini/antigravity-cli/brain/2fa1de3c-b3f6-4d41-8782-b318d84ad998/BRINGUP_STATUS.md) — Master bring-up status log
2. ✅ [CONFIG_ANALYSIS.md](file:///home/sibindev9746_gmail_com/.gemini/antigravity-cli/brain/2fa1de3c-b3f6-4d41-8782-b318d84ad998/CONFIG_ANALYSIS.md) — Defconfig merge order & missing symbol analysis
3. ✅ [CONVERGENCE_REPORT.md](file:///home/sibindev9746_gmail_com/.gemini/antigravity-cli/brain/2fa1de3c-b3f6-4d41-8782-b318d84ad998/CONVERGENCE_REPORT.md) — Linker symbol convergence metrics (44 -> 19 -> 0 symbols)
4. ✅ [KIRISAKURA_COMPARISON_REPORT.md](file:///home/sibindev9746_gmail_com/.gemini/antigravity-cli/brain/2fa1de3c-b3f6-4d41-8782-b318d84ad998/KIRISAKURA_COMPARISON_REPORT.md) — Kirisakura vs Lineage kernel tree diff
5. ✅ [PHASE_1_3_INVESTIGATION_REPORT.md](file:///home/sibindev9746_gmail_com/.gemini/antigravity-cli/brain/2fa1de3c-b3f6-4d41-8782-b318d84ad998/PHASE_1_3_INVESTIGATION_REPORT.md) — Early boot failure root-cause analysis
6. ✅ [PHASE_4_DTS_COMPARISON.md](file:///home/sibindev9746_gmail_com/.gemini/antigravity-cli/brain/2fa1de3c-b3f6-4d41-8782-b318d84ad998/PHASE_4_DTS_COMPARISON.md) — Device tree source comparison
7. ✅ [PREFLASH_VERIFICATION.md](file:///home/sibindev9746_gmail_com/.gemini/antigravity-cli/brain/2fa1de3c-b3f6-4d41-8782-b318d84ad998/PREFLASH_VERIFICATION.md) — Pre-flash 6-point verification report
8. ✅ [ROLLBACK_INFO.md](file:///home/sibindev9746_gmail_com/.gemini/antigravity-cli/brain/2fa1de3c-b3f6-4d41-8782-b318d84ad998/ROLLBACK_INFO.md) — Rollback state and backup pointers
9. ✅ [RUNTIME_COMPARISON_REPORT.md](file:///home/sibindev9746_gmail_com/.gemini/antigravity-cli/brain/2fa1de3c-b3f6-4d41-8782-b318d84ad998/RUNTIME_COMPARISON_REPORT.md) — Stock vs TWRP vs Lineage runtime behavior
10. ✅ [SYSTEMATIC_LINK_REPORT.md](file:///home/sibindev9746_gmail_com/.gemini/antigravity-cli/brain/2fa1de3c-b3f6-4d41-8782-b318d84ad998/SYSTEMATIC_LINK_REPORT.md) — 7 driver cluster linker analysis
11. ✅ [TWRP_COMPARISON_REPORT.md](file:///home/sibindev9746_gmail_com/.gemini/antigravity-cli/brain/2fa1de3c-b3f6-4d41-8782-b318d84ad998/TWRP_COMPARISON_REPORT.md) — TWRP boot image layout comparison
12. ✅ [FINAL_BUILD_REPORT.md](file:///home/sibindev9746_gmail_com/.gemini/antigravity-cli/brain/2fa1de3c-b3f6-4d41-8782-b318d84ad998/FINAL_BUILD_REPORT.md) — Final executive build report

---

## Technical Summary of Achieved Baseline

1. **Clean Kernel Link**: `vmlinux` linked with 0 undefined symbols and 0 duplicate symbols.
2. **Modules & MODPOST**: 184 kernel modules compiled and post-processed cleanly.
3. **Restored OEM Configuration**: Restored 32 Qualcomm & ASUS core drivers from GKI modular (`=m`) to built-in (`=y`) matching `stock_defconfig`.
4. **First-Stage `fstab`**: Restored build-system generated `first_stage_ramdisk/fstab.default` into `vendor_boot.img` (`BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true`).
5. **DTBO Option A**: `BOARD_KERNEL_SEPARATED_DTBO` disabled — device OEM `dtbo` partition remains 100% untouched.

---

## Flashing Instructions

```bash
# 1. Put device into Fastboot mode (Hold Vol Down + Power)

# 2. Flash vendor_boot.img (restores first-stage fstab.default)
fastboot flash vendor_boot out/target/product/rog5s/vendor_boot.img

# 3. Flash custom boot.img (contains Kirisakura ANAKIN_ROG5 kernel Image)
fastboot flash boot out/target/product/rog5s/boot.img

# 4. Reboot
fastboot reboot
```

Standing by for hardware runtime observations!
