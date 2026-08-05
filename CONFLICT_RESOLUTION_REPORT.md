# Bring-up Conflict Resolution Report

This report catalogs all duplicate outputs detected by Kati during the diagnostic build, and classifies them for removal from `proprietary-files.txt`.

## 1. AOSP-Generated Conflicts (Removed)
| Target Path | Build Producer | Justification |
|-------------|----------------|---------------|
| `odm/etc/fs_config_dirs` | AOSP/Core | AOSP auto-generates fs_config, passwd, and sepolicy. |
| `odm/etc/fs_config_files` | AOSP/Core | AOSP auto-generates fs_config, passwd, and sepolicy. |
| `odm/etc/group` | AOSP/Core | AOSP auto-generates fs_config, passwd, and sepolicy. |
| `odm/etc/passwd` | AOSP/Core | AOSP auto-generates fs_config, passwd, and sepolicy. |
| `odm/etc/selinux/precompiled_sepolicy.plat_sepolicy_and_mapping.sha256` | AOSP/Core | AOSP auto-generates fs_config, passwd, and sepolicy. |
| `odm/etc/selinux/precompiled_sepolicy.product_sepolicy_and_mapping.sha256` | AOSP/Core | AOSP auto-generates fs_config, passwd, and sepolicy. |
| `odm/etc/selinux/precompiled_sepolicy.system_ext_sepolicy_and_mapping.sha256` | AOSP/Core | AOSP auto-generates fs_config, passwd, and sepolicy. |
| `odm/etc/selinux/precompiled_sepolicy` | AOSP/Core | AOSP auto-generates fs_config, passwd, and sepolicy. |
| `vendor/bin/applypatch` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/bin/audioadsprpcd` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/bin/awk` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/bin/boringssl_self_test32` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/bin/boringssl_self_test64` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/bin/checkpoint_gc` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/bin/cplay` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/bin/dumpsys` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/bin/hostapd_cli` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/bin/hw/android.hardware.atrace@1.0-service` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/bin/hw/android.hardware.audio.service` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/bin/hw/android.hardware.biometrics.fingerprint@2.1-service` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/bin/hw/android.hardware.boot@1.1-service` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/bin/hw/android.hardware.camera.provider@2.4-service_64` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/bin/hw/android.hardware.cas@1.2-service` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/bin/hw/android.hardware.health@2.1-service` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/bin/hw/android.hardware.lights-service.qti` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/bin/hw/android.hardware.media.omx@1.0-service` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/bin/hw/android.hardware.memtrack@1.0-service` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/bin/hw/android.hardware.nfc@1.2-service` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/bin/hw/android.hardware.sensors@2.0-service.multihal` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/bin/hw/android.hardware.thermal@2.0-service.qti` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/bin/hw/android.hardware.wifi@1.0-service` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/bin/hw/hostapd` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/bin/hw/wpa_supplicant` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/bin/ipacm` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/bin/logwrapper` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/bin/sh` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/bin/toolbox` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/bin/toybox_vendor` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/bin/vndservicemanager` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/bin/vndservice` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/bin/wpa_cli` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/etc/selinux/plat_pub_versioned.cil` | AOSP/SELinux | SELinux policy is compiled by the build system. |
| `vendor/etc/selinux/plat_sepolicy_vers.txt` | AOSP/SELinux | SELinux policy is compiled by the build system. |
| `vendor/etc/selinux/selinux_denial_metadata` | AOSP/SELinux | SELinux policy is compiled by the build system. |
| `vendor/etc/selinux/vendor_file_contexts` | AOSP/SELinux | SELinux policy is compiled by the build system. |
| `vendor/etc/selinux/vendor_hwservice_contexts` | AOSP/SELinux | SELinux policy is compiled by the build system. |
| `vendor/etc/selinux/vendor_mac_permissions.xml` | AOSP/SELinux | SELinux policy is compiled by the build system. |
| `vendor/etc/selinux/vendor_property_contexts` | AOSP/SELinux | SELinux policy is compiled by the build system. |
| `vendor/etc/selinux/vendor_seapp_contexts` | AOSP/SELinux | SELinux policy is compiled by the build system. |
| `vendor/etc/selinux/vendor_sepolicy.cil` | AOSP/SELinux | SELinux policy is compiled by the build system. |
| `vendor/etc/selinux/vendor_service_contexts` | AOSP/SELinux | SELinux policy is compiled by the build system. |
| `vendor/etc/selinux/vndservice_contexts` | AOSP/SELinux | SELinux policy is compiled by the build system. |
| `vendor/lib/hw/android.hardware.audio.effect@2.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib/hw/android.hardware.audio.effect@4.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib/hw/android.hardware.audio.effect@5.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib/hw/android.hardware.audio.effect@6.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib/hw/android.hardware.audio@2.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib/hw/android.hardware.audio@4.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib/hw/android.hardware.audio@5.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib/hw/android.hardware.audio@6.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib/hw/android.hardware.bluetooth.audio@2.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib/hw/android.hardware.camera.provider@2.4-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib/hw/android.hardware.graphics.mapper@3.0-impl-qti-display.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib/hw/android.hardware.graphics.mapper@4.0-impl-qti-display.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib/hw/android.hardware.health@2.0-impl-2.1-qti.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib/hw/android.hardware.memtrack@1.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib/hw/android.hardware.renderscript@1.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib/hw/android.hardware.soundtrigger@2.1-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib/hw/android.hardware.soundtrigger@2.2-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib/hw/android.hardware.soundtrigger@2.3-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib/libOmxAacEnc.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libOmxAmrEnc.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libOmxCore.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libOmxEvrcEnc.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libOmxG711Enc.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libOmxQcelp13Enc.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/liba2dpoffload.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libalsautils.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libavservices_minijail.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libbatterylistener.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libbluetooth_audio_session.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libchrome.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libcirrusspkrprot.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libcld80211.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libcodec2_hidl@1.0.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libcodec2_vndk.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libcomprcapture.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libdisplayconfig.qti.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libdisplaydebug.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libdrm.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libdrmutils.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libeffects.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libeffectsconfig.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libexthwplugin.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libgpu_tonemapper.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libgralloc.qti.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libgralloccore.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libgrallocutils.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libhdmiedid.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libhfp.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libhidltransport.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libhwbinder.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libjson.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libmemutils.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libmm-omxcore.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libnbaio_mono.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libopus.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libplatformconfig.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libprotobuf-cpp-full-3.9.1.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libprotobuf-cpp-lite-3.9.1.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libqdMetaData.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libqdutils.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libqservice.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libqti_vndfwk_detect.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libqtivibratoreffect.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libreference-ril.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libril.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/librilutils.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/librmnetctl.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libsdedrm.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libsdmcore.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libsdmutils.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libsensorndkbridge.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libsndmonitor.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libspkrprot.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libssrec.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_amrnb_common.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_bufferpool@2.0.1.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_enc_common.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_flacdec.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_aacdec.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_aacenc.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_amrdec.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_amrnbenc.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_amrwbenc.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_avcdec.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_avcenc.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_flacdec.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_flacenc.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_g711dec.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_gsmdec.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_hevcdec.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_mp3dec.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_mpeg2dec.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_mpeg4dec.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_mpeg4enc.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_opusdec.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_rawdec.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_vorbisdec.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_vpxdec.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_soft_vpxenc.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_softomx.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefright_softomx_plugin.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libstagefrighthw.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libtinycompress.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libtinyxml.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libvndfwk_detect_jni.qti.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libvorbisidec.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libvpx.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libwfdaac_vendor.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libwifi-hal-ctrl.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libwifi-hal-qcom.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib/libwpa_client.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/hw/android.hardware.audio.effect@2.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib64/hw/android.hardware.audio.effect@4.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib64/hw/android.hardware.audio.effect@5.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib64/hw/android.hardware.audio.effect@6.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib64/hw/android.hardware.audio@2.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib64/hw/android.hardware.audio@4.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib64/hw/android.hardware.audio@5.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib64/hw/android.hardware.audio@6.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib64/hw/android.hardware.bluetooth.audio@2.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib64/hw/android.hardware.camera.provider@2.4-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib64/hw/android.hardware.graphics.mapper@3.0-impl-qti-display.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib64/hw/android.hardware.graphics.mapper@4.0-impl-qti-display.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib64/hw/android.hardware.health@2.0-impl-2.1-qti.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib64/hw/android.hardware.memtrack@1.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib64/hw/android.hardware.renderscript@1.0-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib64/hw/android.hardware.soundtrigger@2.2-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib64/hw/android.hardware.soundtrigger@2.3-impl.so` | AOSP/HALs | Standard Android HIDL/AIDL HAL implementations built from source. |
| `vendor/lib64/libOmxAacEnc.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libOmxAmrEnc.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libOmxCore.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libOmxEvrcEnc.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libOmxG711Enc.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libOmxQcelp13Enc.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/liba2dpoffload.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libalsautils.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libavservices_minijail.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libavservices_minijail_vendor.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libbatterylistener.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libbluetooth_audio_session.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libcamera2ndk_vendor.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libchrome.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libcirrusspkrprot.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libcld80211.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libcodec2_hidl@1.0.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libcodec2_hidl@1.1.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libcodec2_vndk.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libcomprcapture.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libdisplayconfig.qti.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libdisplaydebug.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libdrm.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libdrmutils.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libeffects.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libeffectsconfig.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libexthwplugin.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libgpu_tonemapper.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libgralloc.qti.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libgralloccore.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libgrallocutils.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libhdmiedid.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libhfp.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libhidltransport.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libhistogram.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libhwbinder.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libipanat.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libjson.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libkeystore-engine-wifi-hidl.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libkeystore-wifi-hidl.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libmemutils.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libmm-omxcore.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libnbaio_mono.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libnetfilter_conntrack.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libnfnetlink.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/liboffloadhal.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libplatformconfig.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libprotobuf-cpp-full-3.9.1.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libprotobuf-cpp-lite-3.9.1.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libqdMetaData.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libqdutils.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libqservice.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libqti_vndfwk_detect.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libqtivibratoreffect.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libreference-ril.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libril.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/librilutils.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/librmnetctl.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libsdedrm.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libsdmcore.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libsdmutils.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libsensorndkbridge.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libsndmonitor.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libspkrprot.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libssrec.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libstagefright_bufferpool@2.0.1.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libstagefright_softomx.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libstagefrighthw.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libtinycompress.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libtinyxml.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libusb.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libvndfwk_detect_jni.qti.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libwifi-hal-ctrl.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libwifi-hal-qcom.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libwifi-hal.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |
| `vendor/lib64/libwpa_client.so` | AOSP/Core | Standard AOSP libs/bins like logwrapper, sh, toolbox, libfmq, etc. |

## 2. Device-Generated Conflicts (Removed proprietary copy)
| Target Path | Build Producer | Justification |
|-------------|----------------|---------------|
| `vendor/bin/hw/vendor.qti.hardware.display.allocator-service` | QCOM/CAF | Qualcomm CAF vendor modules built from source hardware/qcom or device tree. |
| `vendor/bin/hw/vendor.qti.hardware.display.composer-service` | QCOM/CAF | Qualcomm CAF vendor modules built from source hardware/qcom or device tree. |
| `vendor/bin/hw/vendor.qti.hardware.vibrator.service` | QCOM/CAF | Qualcomm CAF vendor modules built from source hardware/qcom or device tree. |
| `vendor/bin/init.class_main.sh` | Device/Init | Device init scripts generated by makefiles. |
| `vendor/bin/init.qcom.early_boot.sh` | Device/Init | Device init scripts generated by makefiles. |
| `vendor/bin/init.qcom.sh` | Device/Init | Device init scripts generated by makefiles. |
| `vendor/bin/init.qcom.usb.sh` | Device/Init | Device init scripts generated by makefiles. |
| `vendor/bin/init.qti.display_boot.sh` | Device/Init | Device init scripts generated by makefiles. |
| `vendor/etc/IPACM_cfg.xml` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/fs_config_dirs` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/fs_config_files` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/fstab.default` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/group` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/android.hardware.atrace@1.0-service.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/android.hardware.audio.service.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/android.hardware.biometrics.fingerprint@2.1-service.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/android.hardware.boot@1.1-service.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/android.hardware.camera.provider@2.4-service_64.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/android.hardware.cas@1.2-service.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/android.hardware.health@2.1-service.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/android.hardware.lights-qti.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/android.hardware.media.omx@1.0-service.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/android.hardware.memtrack@1.0-service.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/android.hardware.nfc@1.2-service.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/android.hardware.sensors@2.0-service-multihal.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/android.hardware.thermal@2.0-service.qti.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/android.hardware.wifi@1.0-service.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/boringssl_self_test.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/hostapd.android.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/hw/init.qcom.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/hw/init.target.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/init.qti.display_boot.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/ipacm.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/vendor.qti.audio-adsprpc-service.rc` | QCOM/CAF | Qualcomm CAF vendor modules built from source hardware/qcom or device tree. |
| `vendor/etc/init/vendor.qti.hardware.display.allocator-service.rc` | QCOM/CAF | Qualcomm CAF vendor modules built from source hardware/qcom or device tree. |
| `vendor/etc/init/vendor.qti.hardware.display.composer-service.rc` | QCOM/CAF | Qualcomm CAF vendor modules built from source hardware/qcom or device tree. |
| `vendor/etc/init/vendor.qti.hardware.vibrator.service.rc` | QCOM/CAF | Qualcomm CAF vendor modules built from source hardware/qcom or device tree. |
| `vendor/etc/init/vendor_flash_recovery.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/init/vndservicemanager.rc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/mkshrc` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/passwd` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/wifi/wpa_supplicant.conf` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/android.hardware.audio.common-util.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/android.hardware.audio.common@2.0-util.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/android.hardware.audio.common@4.0-util.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/android.hardware.audio.common@5.0-util.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/android.hardware.audio.common@6.0-util.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/android.hardware.camera.provider@2.4-external.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/android.hardware.camera.provider@2.4-legacy.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/android.hardware.sensors@2.0-ScopedWakelock.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/camera.device@1.0-impl.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/camera.device@3.2-impl.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/camera.device@3.3-impl.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/camera.device@3.4-external-impl.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/camera.device@3.4-impl.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/camera.device@3.5-external-impl.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/camera.device@3.5-impl.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/camera.device@3.6-external-impl.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/com.dsi.ant@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/ese_client.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/ese_spi_nxp.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/hal_libnfc.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/hw/audio.bluetooth.default.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/hw/audio.primary.default.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/hw/audio.primary.lahaina.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/hw/audio.r_submix.default.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/hw/audio.usb.default.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/hw/gralloc.default.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/hw/lights.qcom.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/hw/local_time.default.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/hw/memtrack.default.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/hw/power.default.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/hw/sound_trigger.primary.lahaina.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/hw/vibrator.default.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/mediacas/libclearkeycasplugin.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/mediadrm/libdrmclearkeyplugin.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/nfc_nci_nxp.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/soundfx/libaudiopreprocessing.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/soundfx/libbundlewrapper.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/soundfx/libdownmix.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/soundfx/libdynproc.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/soundfx/libeffectproxy.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/soundfx/libldnhncr.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/soundfx/libqcompostprocbundle.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/soundfx/libqcomvisualizer.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/soundfx/libqcomvoiceprocessing.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/soundfx/libreverbwrapper.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/soundfx/libvisualizer.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/soundfx/libvolumelistener.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.display.config@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.display.config@1.1.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.display.config@1.10.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.display.config@1.11.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.display.config@1.12.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.display.config@1.13.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.display.config@1.14.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.display.config@1.15.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.display.config@1.2.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.display.config@1.3.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.display.config@1.4.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.display.config@1.5.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.display.config@1.6.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.display.config@1.7.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.display.config@1.8.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.display.config@1.9.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.display.config@2.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.nxp.eventprocessor@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.nxp.nxpese@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.nxp.nxpnfc@2.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.nxp.nxpnfclegacy@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.bluetooth_audio@2.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.bluetooth_audio@2.1.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.btconfigstore@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.btconfigstore@2.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.camera.device@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.camera.postproc@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.capabilityconfigstore@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.display.allocator@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.display.allocator@3.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.display.allocator@4.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.display.composer@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.display.composer@2.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.display.mapper@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.display.mapper@1.1.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.display.mapper@2.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.display.mapper@3.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.display.mapper@4.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.display.mapperextensions@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.display.mapperextensions@1.1.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.perf@2.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.perf@2.1.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.perf@2.2.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.servicetracker@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.servicetracker@1.1.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib/vendor.qti.hardware.servicetracker@1.2.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/android.hardware.audio.common-util.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/android.hardware.audio.common@2.0-util.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/android.hardware.audio.common@4.0-util.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/android.hardware.audio.common@5.0-util.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/android.hardware.audio.common@6.0-util.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/android.hardware.camera.provider@2.4-external.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/android.hardware.camera.provider@2.4-legacy.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/android.hardware.sensors@2.0-ScopedWakelock.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/camera.device@1.0-impl.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/camera.device@3.2-impl.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/camera.device@3.3-impl.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/camera.device@3.4-external-impl.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/camera.device@3.4-impl.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/camera.device@3.5-external-impl.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/camera.device@3.5-impl.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/camera.device@3.6-external-impl.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/com.dsi.ant@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/ese_client.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/ese_spi_nxp.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/hal_libnfc.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/hw/audio.bluetooth.default.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/hw/audio.primary.default.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/hw/audio.primary.lahaina.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/hw/audio.r_submix.default.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/hw/audio.usb.default.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/hw/fingerprint.default.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/hw/gralloc.default.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/hw/lights.qcom.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/hw/local_time.default.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/hw/memtrack.default.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/hw/power.default.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/hw/sound_trigger.primary.lahaina.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/hw/vibrator.default.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/mediacas/libclearkeycasplugin.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/mediadrm/libdrmclearkeyplugin.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/nfc_nci_nxp.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/soundfx/libaudiopreprocessing.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/soundfx/libbundlewrapper.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/soundfx/libdownmix.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/soundfx/libdynproc.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/soundfx/libeffectproxy.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/soundfx/libldnhncr.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/soundfx/libqcompostprocbundle.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/soundfx/libqcomvisualizer.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/soundfx/libqcomvoiceprocessing.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/soundfx/libreverbwrapper.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/soundfx/libvisualizer.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/soundfx/libvolumelistener.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.display.config@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.display.config@1.1.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.display.config@1.10.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.display.config@1.11.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.display.config@1.12.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.display.config@1.13.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.display.config@1.14.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.display.config@1.15.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.display.config@1.2.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.display.config@1.3.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.display.config@1.4.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.display.config@1.5.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.display.config@1.6.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.display.config@1.7.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.display.config@1.8.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.display.config@1.9.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.display.config@2.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.nxp.eventprocessor@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.nxp.nxpese@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.nxp.nxpnfc@2.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.nxp.nxpnfclegacy@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.bluetooth_audio@2.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.bluetooth_audio@2.1.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.btconfigstore@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.btconfigstore@2.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.camera.device@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.camera.postproc@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.capabilityconfigstore@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.display.allocator@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.display.allocator@3.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.display.allocator@4.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.display.composer@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.display.composer@2.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.display.composer@3.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.display.mapper@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.display.mapper@1.1.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.display.mapper@2.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.display.mapper@3.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.display.mapper@4.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.display.mapperextensions@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.display.mapperextensions@1.1.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.fstman@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.perf@2.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.perf@2.1.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.perf@2.2.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.servicetracker@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.servicetracker@1.1.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.servicetracker@1.2.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.vibrator.impl.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.wifi.hostapd@1.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.wifi.hostapd@1.1.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.wifi.hostapd@1.2.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.wifi.supplicant@2.0.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.wifi.supplicant@2.1.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/lib64/vendor.qti.hardware.wifi.supplicant@2.2.so` | Device/Other | Other device/QCOM source built modules. |
| `vendor/build.prop` | Device/Other | Other device/QCOM source built modules. |
| `odm/etc/build.prop` | Device/Other | Other device/QCOM source built modules. |
| `vendor/etc/NOTICE.xml.gz` | Device/Other | Other device/QCOM source built modules. |
| `odm/etc/NOTICE.xml.gz` | Device/Other | Other device/QCOM source built modules. |
