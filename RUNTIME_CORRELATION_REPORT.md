# Empirical Correlation Report: Runtime Artifact Synthesis

> **Objective**: Correlate all recovered runtime logs to determine the exact failure mechanism causing the 4-reboot Fastboot loop.

---

## 1. Multi-Artifact Correlation Matrix

| Artifact | Source Location | Key Empirical Findings | Scientific Conclusion |
|:---|:---|:---|:---|
| **`logfs`** | `/dev/block/by-name/logfs` | `DevInfo.verify_vbmeta_ret = 3`, `Allow skip AVB_SLOT_VERIFY_RESULT_ERROR_ROLLBACK_INDEX` | ABL logs AVB hash warnings as non-fatal on unlocked bootloader; **AVB does NOT cause reboot**. |
| **`last_kmsg`** | `/asdf/last_kmsg` | Kernel init proceeds cleanly up to 25.7s into userspace init | Kernel core, ARM64 MMU, UFS storage controller, and initial init execution are **100% operational**. |
| **`tombstones` (06 & 31)** | `/data/tombstones/` | `SIGSEGV` in `camera.qcom.so` (`CamX::SettingPropertyCallback+64`) | Vendor camera HAL crashed during system property enumeration. |
| **`ASUSEvtlog.txt`** | `/asdf/ASUSEvtlog.txt` | `Power off Reason: 0x0 => [Reset via PS_HOLD]`, `Bootup Reason: => [ HARD_RESET ]` | Hardware reset line `PS_HOLD` was pulled low by Qualcomm PMIC / watchdog. |
| **`asdf-logcat.txt`** | `/asdf/asdf-logcat.txt` | `[40.28s] bootanim exited 0`, `[40.54s] Boot completed`, `Fatal signal 6 (SIGABRT) in tid 4115 (init)` | Android `init` self-terminates with `SIGABRT` when a `critical` service or HAL fails repeatedly. |

---

## 2. Evaluation of 5 Reboot Trigger Hypotheses

| Hypothesis Category | Empirical Finding | Status |
|:---|:---|:---:|
| **1. Early ABL / AVB Abort** | ABL logs show `verify_vbmeta_ret = 3` (unlocked) and explicitly skips AVB error. | ❌ **Ruled Out** |
| **2. Kernel Panic in Early Drivers** | `last_kmsg` shows 0 kernel panics, 0 oops, and 0 NULL pointer crashes in kernel space. | ❌ **Ruled Out** |
| **3. Init Failure / Critical Service Exit** | Logcat shows `init` receiving `SIGABRT` (code -1) right after service initialization fails. | ⚠️ **Confirmed Contributor** |
| **4. APEX Checkpoint Rollback Loop** | `apexd` logged `Native process 'vendor.camera-provider-2-4' is crashing. Attempting a revert.` | ⚠️ **Confirmed Contributor** |
| **5. PMIC / Watchdog Reset (`PS_HOLD`)** | `ASUSEvtlog.txt` records `Power off Reason: 0x0 => [Reset via PS_HOLD]`. | ✅ **Confirmed Execution Mechanism** |

---

## 3. Unified Failure Chain

```text
[ABL Bootloader]
  │ (AVB errors skipped via verify_vbmeta_ret=3)
  ▼
[Linux Kernel 5.4.210]
  │ (Storage, Display, Subsystems probe cleanly)
  ▼
[Android Init & Userspace]
  │
  ├──> vendor.camera-provider-2-4 / critical HAL service crashes
  │
  ├──> apexd detects HAL failure during APEX Checkpoint Mode
  │
  ├──> init receives SIGABRT / sys.powerctl=reboot issued
  │
  └──> PMIC pulls PS_HOLD low (HARD_RESET) ──> 4 Retries ──> Fastboot
```
