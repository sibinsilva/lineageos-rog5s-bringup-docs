# CONFIG Change Analysis: Build Compatibility vs Functional Changes

> Cross-referenced against:
> - `kernel/asus/sm8350_lineage_backup/arch/arm64/configs/vendor/rog5s.config` (stock ASUS fragment)
> - `gki_defconfig` + `lahaina_GKI.config` + `lahaina_QGKI.config` + `lahaina_consolidate.config` (base chain)
> - `kirisakura_defconfig` (the Kirisakura tree's own reference config)

---

## Category 1 — Stock ASUS Config Restorations
These were already in `rog5s.config` or the base chain; our fragment restores them.

| Config | Stock rog5s.config | Base chain | Verdict |
|--------|-------------------|------------|---------|
| `CONFIG_MACH_ASUS_ZS673KS=y` | ✅ `=y` | Not in base | **Restoring stock** — required for board ID and `KBUILD_CPPFLAGS += -DASUS_ZS673KS_PROJECT=1` |
| `CONFIG_TOUCHSCREEN_ROG=y` | ✅ `=y` | Not in base | **Restoring stock** — ASUS ROG touchscreen primary driver |
| `CONFIG_ASUS_GLOBAL_VAR=y` | ✅ `=y` | Not in base | **Restoring stock** — ASUS BSP global variable subsystem |
| `CONFIG_INPUT_TOUCHSCREEN=y` | Not in rog5s.config | ✅ `=y` in `gki_defconfig` | **Restoring stock** — was in GKI base, got dropped |
| `CONFIG_MAILBOX=y` | Not in rog5s.config | ✅ `=y` in `gki_defconfig` | **Restoring stock** — was in GKI base, required for QCOM IPC |
| `CONFIG_QCOM_SMEM=y` | Not in rog5s.config | ✅ `=m` in `lahaina_GKI.config` | **Restoring stock** — built-in vs module, QCOM shared memory |
| `CONFIG_QCOM_SMP2P=y` | Not in rog5s.config | ✅ `=m` in `lahaina_GKI.config` | **Restoring stock** — QCOM SMP2P inter-processor communication |
| `CONFIG_QCOM_WDT_CORE=y` | Not in rog5s.config | ✅ `=m` in `lahaina_GKI.config` | **Restoring stock** — QCOM watchdog, essential for stable boot |

> **Note on `=m` vs `=y`:** SMEM, SMP2P, and WDT are `=m` in the base chain. We set them `=y` (built-in) because the Kirisakura tree targets a non-GKI monolithic build. These were modules in Lineage's GKI build; making them built-in is correct and expected for a boot-critical non-GKI kernel.

---

## Category 2 — Build Compatibility Fixes
Required to compile successfully; not changing runtime behavior.

| Config | Stock value | Our value | Reason |
|--------|-------------|-----------|--------|
| `CONFIG_I2C=y` | Not explicit (auto-enabled via `I2C_MSM_GENI=y` in base chain — `I2C_MSM_GENI` selects `I2C`) | Not resolved by Kirisakura merge | **Build fix** — `drivers/aura_sync/` is `obj-y` unconditionally; calls `i2c_transfer` which is gated on `IS_ENABLED(CONFIG_I2C)`. Without this, the aura_sync drivers fail to compile. In stock, `I2C_MSM_GENI=y` in lahaina_QGKI would have `select I2C` automatically. |
| `CONFIG_RPS=y` | Not explicitly set anywhere; `default y` when `SMP && SYSFS` (both true) | `=y` in our fragment | **Build fix** — `techpack/datarmnet-ext/shs/rmnet_shs_main.c` uses `rps_map` struct member with no `#ifdef CONFIG_RPS` guards. `CONFIG_RPS` has `default y` in Kconfig so stock would always have it enabled. Our explicit `=y` makes it deterministic. No runtime change vs stock. |
| `CONFIG_TOUCHSCREEN_SYNAPTICS_TCM=y` | Not in rog5s.config (was in the Lineage-added ROG5s config) | `=y` | Required to compile `synaptics_tcm/` driver tree that is `obj-y` in the Kirisakura Makefile. |
| `CONFIG_CGF_NOTIFY_EVENT=y` | Not in stock rog5s.config | `=y` | Required by `kernel/signal.c` ASUS cgroup freeze notification hook. Without it, incomplete type errors occur. Already in our defconfig from before. |

---

## Category 3 — `CONFIG_BUILD_ARM64_DT_OVERLAY` — Requires Decision

This is the most important item. Full picture:

### Config merge chain outcome (without our override):
```
kirisakura_defconfig:          CONFIG_BUILD_ARM64_DT_OVERLAY=y  ← sets it ON
lahaina_GKI.config:            (not mentioned)
lahaina_QGKI.config:           (not mentioned)
lahaina_consolidate.config:    (not mentioned)
ZS673KS-perf_defconfig:        # CONFIG_BUILD_ARM64_DT_OVERLAY is not set  ← we turn it OFF
```

### The two flags and their relationship:
| Flag | Location | Effect |
|------|----------|--------|
| `BOARD_KERNEL_SEPARATED_DTBO` (commented out) | `BoardConfig.mk` | Controls whether Android build packages `.dtbo` files into `dtbo.img` |
| `CONFIG_BUILD_ARM64_DT_OVERLAY` | kernel defconfig | Controls whether the kernel actually compiles `.dtbo` files |

### Why they were both disabled:
`BOARD_KERNEL_SEPARATED_DTBO := true` was originally in `BoardConfig.mk`. When that flag is set, `mkdtboimg.py` runs and **requires** at least one `.dtbo` file as input. The Kirisakura `kirisakura_defconfig` sets `CONFIG_BUILD_ARM64_DT_OVERLAY=y`, so the kernel *would* normally produce `.dtbo` files. However, we disabled it per SKILL.md guidance.

### Was it in the stock ASUS kernel?
- `rog5s.config` does **not** mention it → it was governed by `kirisakura_defconfig=y`
- Stock ASUS OEM kernel: **yes, had DT overlay enabled** (Kirisakura ships with it on)

### Is our override required for the build to complete?

**Yes, under the current BoardConfig.mk.** The constraint is:
- `BOARD_KERNEL_SEPARATED_DTBO` is currently **commented out** (we did this)  
- `mkdtboimg.py` only runs when `BOARD_KERNEL_SEPARATED_DTBO=true`  
- Therefore `CONFIG_BUILD_ARM64_DT_OVERLAY` is irrelevant to the current build completing

**Both paths are self-consistent:**

| Option A (current) | Option B (restore stock) |
|-------------------|--------------------------|
| `BOARD_KERNEL_SEPARATED_DTBO` commented out | `BOARD_KERNEL_SEPARATED_DTBO := true` |
| `# CONFIG_BUILD_ARM64_DT_OVERLAY is not set` | `CONFIG_BUILD_ARM64_DT_OVERLAY=y` |
| No `.dtbo` files produced, no `dtbo.img` packaged | `.dtbo` files produced, packaged into `dtbo.img` |
| **Boot risk per SKILL.md:** kernel panics if dtbo partition has different overlays | **Boot risk:** none if `dtbo.img` is also flashed alongside |

### Recommendation

Since the goal is single-cause attribution:

1. **Remove our `# CONFIG_BUILD_ARM64_DT_OVERLAY is not set` override** — let `kirisakura_defconfig=y` take effect
2. **Restore `BOARD_KERNEL_SEPARATED_DTBO := true`** in `BoardConfig.mk`
3. This restores the full stock DT overlay flow — the device's existing `dtbo` partition was flashed with the OEM kernel's overlays, so the new overlays should match

**Or**, if you prefer the cautious approach (no dtbo changes in this build):
1. Keep `BOARD_KERNEL_SEPARATED_DTBO` commented out
2. Remove the `# CONFIG_BUILD_ARM64_DT_OVERLAY is not set` override (let Kirisakura build dtbo files internally but don't package them into `dtbo.img`)

> Both are valid. The user should decide based on whether they plan to flash `dtbo.img` alongside `boot.img`.

---

## Summary Classification

| Config | Class | Can it be removed? |
|--------|-------|--------------------|
| `CONFIG_MACH_ASUS_ZS673KS=y` | Stock restoration | No — critical for board identity |
| `CONFIG_INPUT_TOUCHSCREEN=y` | Stock restoration | No — touchscreen won't bind |
| `CONFIG_TOUCHSCREEN_ROG=y` | Stock restoration | No — primary touch driver |
| `CONFIG_ASUS_GLOBAL_VAR=y` | Stock restoration | No — compile error if removed |
| `CONFIG_MAILBOX=y` | Stock restoration | No — IPC subsystem dependency |
| `CONFIG_QCOM_SMEM=y` | Stock restoration (=m → =y) | No — shared memory required |
| `CONFIG_QCOM_SMP2P=y` | Stock restoration (=m → =y) | No — inter-processor signaling |
| `CONFIG_QCOM_WDT_CORE=y` | Stock restoration (=m → =y) | No — watchdog required |
| `CONFIG_I2C=y` | Build fix (auto-enabled in stock) | No — compile error |
| `CONFIG_RPS=y` | Build fix (default y in stock) | No — compile error |
| `CONFIG_TOUCHSCREEN_SYNAPTICS_TCM=y` | Build fix | No — compile error |
| `CONFIG_CGF_NOTIFY_EVENT=y` | Build fix | No — compile error |
| `# CONFIG_BUILD_ARM64_DT_OVERLAY is not set` | **Debatable** | **Yes — see above** |
