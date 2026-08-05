# Kernel Module Verification Report
**Device:** ASUS ROG Phone 5s (ZS676KS / SM8350)
**Firmware Reference:** Android 13 (.200) Stock `vendor.img`

## 1. Present (81 Modules)
These modules were built by our open-source kernel tree and match the stock `modules.load` filenames identically.

```text
fc0012.ko, mt2060.ko, wcd938x_slave_dlkm.ko, swr_ctrl_dlkm.ko, slimbus-ngd.ko, rx_macro_dlkm.ko, r820t.ko, tx_macro_dlkm.ko, wcd9xxx_dlkm.ko, tuner-simple.ko, tea5761.ko, mt2266.ko, stub_dlkm.ko, swr_dmic_dlkm.ko, pinctrl_lpi_dlkm.ko, wcd937x_dlkm.ko, q6_pdr_dlkm.ko, tuner-xc2028.ko, bolero_cdc_dlkm.ko, tda18218.ko, xc4000.ko, it913x.ko, bt_fm_slim.ko, qt1010.ko, wsa883x_dlkm.ko, mbhc_dlkm.ko, mxl301rf.ko, tda18212.ko, q6_notifier_dlkm.ko, tea5767.ko, mxl5007t.ko, swr_haptics_dlkm.ko, apr_dlkm.ko, fc2580.ko, qm1d1b0004.ko, slimbus.ko, camera.ko, mc44s803.ko, native_dlkm.ko, tua9001.ko, swr_dlkm.ko, e4000.ko, tda18250.ko, wcd937x_slave_dlkm.ko, snd_event_dlkm.ko, mt2063.ko, tda9887.ko, rdbg.ko, msm_drm.ko, adsp_loader_dlkm.ko, hid-aksys.ko, mxl5005s.ko, wsa_macro_dlkm.ko, wcd938x_dlkm.ko, tuner-types.ko, si2157.ko, mt20xx.ko, xc5000.ko, q6_dlkm.ko, mt2131.ko, msi001.ko, m88rs6000t.ko, qcom_edac.ko, wcd_core_dlkm.ko, max2165.ko, llcc_perfmon.ko, qm1d1c0042.ko, fc0011.ko, hdmi_dlkm.ko, cs35l45_i2c_dlkm.ko, pinctrl_wcd_dlkm.ko, gf_spi.ko, fc0013.ko, btpower.ko, platform_dlkm.ko, machine_dlkm.ko, va_macro_dlkm.ko, rmnet_core.ko, rmnet_ctl.ko, rmnet_offload.ko, rmnet_shs.ko
```

## 2. Renamed / Replaced (3 Modules)
These modules are produced by our kernel tree but under different filenames. They have been mapped in our sanitized `modules.load`.

* `qca_cld3_wlan.ko` -> **`wlan.ko`** *(Qualcomm WLAN driver)*
* `focaltech_fts_rog.ko` -> **`focaltech_fts_zf.ko`** *(ZenFone variant of Focaltech touchscreen)*
* `focaltech_fts_rog2.ko` -> **`focaltech_fts_zf.ko`**

## 3. Missing (16 Modules)
These modules are explicitly requested by stock but are missing from our open-source kernel build. They have been safely omitted from `modules.load`.

| Module | Purpose | Status |
|--------|---------|--------|
| `snd-soc-es928x.ko` | ESS DAC Audio | Proprietary ASUS out-of-tree hardware module. Omitted. |
| `sx932x_2nd.ko` | Semtech SAR sensors (AirTriggers) | Proprietary ASUS out-of-tree hardware module. Omitted. |
| `sx932x.ko` | Semtech SAR sensors (AirTriggers) | Proprietary ASUS out-of-tree hardware module. Omitted. |
| `ms51_phone.ko` | Nuvoton Microcontroller (RGB Lighting) | Proprietary ASUS out-of-tree hardware module. Omitted. |
| `ms51_backcover.ko` | Nuvoton Microcontroller (RGB Fan) | Proprietary ASUS out-of-tree hardware module. Omitted. |
| `tntfs.ko` | Tuxera NTFS Filesystem | Proprietary third-party filesystem. Omitted. |
| `texfat.ko` | Tuxera exFAT Filesystem | Proprietary third-party filesystem. Omitted. |
| `radio-i2c-rtc6226-qca.ko` | FM Radio | Out-of-tree hardware module. Omitted. |
| `lid.ko` | Hall effect sensor | Accessory hardware module. Omitted. |
| `lid_2.ko` | Hall effect sensor | Accessory hardware module. Omitted. |
| `sla.ko` | Smart Link Aggregation | Network aggregation module. Omitted. |
