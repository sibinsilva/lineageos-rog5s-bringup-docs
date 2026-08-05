# 🔬 Controlled Android Userspace Bring-Up Protocol

**Target Device**: ASUS ROG Phone 5S (`ZS676KS` / `ASUS_I005D` / Snapdragon 888 SM8350)  
**Date**: August 3, 2026  
**Methodology**: Standard Android Device Bring-Up Protocol (Single-Hypothesis Isolated Testing)

---

## 📜 1. Strict Workflow Rules

For every change in this bring-up process, the following workflow is strictly enforced:

1. State a **single hypothesis**.
2. Explain **why** that hypothesis matches the observed behavior.
3. Make **one isolated change only**.
4. Describe exactly **what observation will confirm or refute** the hypothesis.
5. Do not introduce multiple debugging changes in one commit.

---

## 🧪 2. Active Experiment 1: SELinux Enforcing vs Permissive

### Hypothesis:
> *If the device is hanging because SELinux is preventing critical userspace services (`SurfaceFlinger`, `vendor.qti.hardware.display.composer-service`, `hwservicemanager`, etc.) from starting or accessing Binder IPC, then booting with `androidboot.selinux=permissive` will allow Android userspace to progress further or produce additional runtime evidence.*

### Isolated Change:
- Commit `3d2b1b8` in `device/asus/rog5s/BoardConfig.mk`:
  ```makefile
  BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive
  ```

### Validation Criteria:
- **Confirmation**: Device boots past the ASUS ROG logo into the LineageOS Boot Animation / Setup Wizard, OR ADB becomes available in userspace.
- **Refutation**: Device remains hung indefinitely at the ASUS ROG logo without ADB access.
  - *If refuted*: SELinux enforcement is immediately eliminated as the primary cause of the hang, and we move to the next single hypothesis.

---

## 📋 3. 10-Point Userspace Progression Checklist

For every test, we evaluate the exact stage reached:

1. **First-Stage `init`**: Unpacks ramdisk, mounts `/dev`, `/proc`, `/sys`.
2. **Second-Stage `init`**: Executes `/system/bin/init`, mounts `/vendor` and `/system`.
3. **`servicemanager`**: Starts AOSP Binder IPC directory daemon.
4. **`hwservicemanager`**: Starts HIDL HAL IPC directory daemon.
5. **`vndservicemanager`**: Starts Vendor Binder IPC directory daemon.
6. **Display Composer HAL**: `vendor.qti.hardware.display.composer-service` registers with `hwservicemanager`.
7. **`SurfaceFlinger`**: Connects to Display Composer HAL and sets up graphics framebuffers.
8. **`Zygote64_32`**: Pre-loads ART classes and listens on `/dev/socket/zygote`.
9. **`SystemServer`**: Launches ActivityManager, PackageManager, WindowManager.
10. **`adbd`**: FunctionFS endpoint opens and USB controller `a600000.dwc3` binds to PC.
