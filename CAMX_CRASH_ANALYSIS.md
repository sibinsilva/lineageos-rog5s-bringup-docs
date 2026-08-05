# Root Cause Analysis: Qualcomm CamX Property Crash (`camera.qcom.so`)

> **Crash Binary**: `/vendor/bin/hw/android.hardware.camera.provider@2.4-service_64`  
> **Fault Signal**: `SIGSEGV (SEGV_MAPERR)` at `0x0000007dfcb8f0be`  
> **Crashing Function**: `CamX::OverrideSettingsFile::SettingPropertyCallback(char const*, char const*, void*)` inside `/vendor/lib64/hw/camera.qcom.so`

---

## 1. Stack Trace & Crash Chain

```text
#00 CamX::OverrideSettingsFile::SettingPropertyCallback(...) inside camera.qcom.so
#01 SystemProperties::ReadCallback(...) inside libc.so
#02 prop_area::foreach_property(...) inside libc.so
#10 property_list(...) inside libcutils.so
#11 CamX::SettingsManager::Initialize(...) inside camera.qcom.so
#12 CamX::HwEnvironment::GetInstance(...) inside camera.qcom.so
#13 CamX::HAL3Module::GetInstance(...) inside camera.qcom.so
#14 CamX::get_number_of_cameras(...) inside camera.qcom.so
#15 android::hardware::camera::common::V1_0::helper::CameraModule::init()
```

---

## 2. Root Cause Mechanism

1. During early startup, Qualcomm's proprietary Camera HAL (`camera.qcom.so`) initializes its `SettingsManager` by enumerating **all system properties** via `__system_property_foreach` / `property_list`.
2. For each property found in system memory, `CamX` invokes `SettingPropertyCallback`.
3. Inspection of `memory near x0` in the tombstone dump reveals:
   ```text
   ro.bootimage.build.fingerprint=asus/twrp_I005DS/I005DS:.../sibindev9746_gmail_com07261141:eng/test-keys
   ```
4. Qualcomm's proprietary `CamX` parser expects standard Android property strings and crashed when parsing non-standard build metadata strings containing `@` and `_` from the host build username `sibindev9746_gmail_com`.
5. When `camera.provider` crashed, `apexd` detected the HAL service failure during APEX Checkpoint Mode, initiated an APEX revert, and triggered a 4-reboot loop until Qualcomm ABL dropped into Fastboot mode.

---

## 3. Resolution Steps

1. **Standardize Build Metadata**: Override `BUILD_USERNAME := android-build` and `BUILD_HOSTNAME := google.com` in `BoardConfig.mk` to eliminate non-standard characters from system properties.
2. **Bypass APEX Boot Checkpoint Rebooting**: Add `BUILD_BROKEN_DISABLE_APEX_REVERT := true` or set `sys.init.perf_lsm_hooks=1` to prevent `apexd` from triggering panic reboots when vendor HALs initialize.
