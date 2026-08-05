# Systematic Link Error Analysis (`vmlinux` Build Task `task-4359`)

> Total remaining undefined symbol groups: **8 driver clusters**  
> All 8 clusters are caused by GKI module demotions where parent subsystem configs were set to `=m` in `lahaina_GKI.config`.

---

## Systematic Symbol & Provider Mapping

### Cluster 1 — QCOM LLCC (Last Level Cache Controller)
- **Undefined Symbols**: `llcc_slice_getd`, `llcc_slice_putd`, `llcc_slice_activate`, `llcc_slice_deactivate`, `llcc_get_slice_id`
- **Caller Objects**: `adreno.o`, `adreno_a6xx.o`, `cvp_hfi.o`, `sde_hw_catalog.o`
- **Provider Object**: `drivers/soc/qcom/llcc-qcom.o` / `llcc-slice.o`
- **Required Config**: `CONFIG_QCOM_LLCC=y`
- **Root Cause**: `CONFIG_QCOM_LLCC=m` in `lahaina_GKI.config`. Built-in display (`sde`) and GPU (`adreno`) drivers link against LLCC APIs directly.
- **Stock Value**: `CONFIG_QCOM_LLCC=y` in `stock_defconfig`.

---

### Cluster 2 — QCOM KGSL IOMMU (GPU Memory Management Unit)
- **Undefined Symbols**: `kgsl_iommu_probe`, `adreno_iommu_init`, `adreno_iommu_set_pt_ctx`
- **Caller Objects**: `kgsl_mmu.o`, `adreno.o`, `adreno_drawctxt.o`
- **Provider Object**: `drivers/gpu/msm/kgsl_iommu.o`
- **Required Config**: `CONFIG_QCOM_KGSL_IOMMU=y` (or `CONFIG_MSM_KGSL_IOMMU=y`)
- **Root Cause**: `CONFIG_MSM_KGSL=y` is built-in, but `kgsl_iommu.c` was excluded because `CONFIG_QCOM_KGSL_IOMMU` was not set to `=y`.
- **Stock Value**: `CONFIG_QCOM_KGSL_IOMMU=y` in `stock_defconfig`.

---

### Cluster 3 — USB UCSI GLINK (Type-C Power Delivery)
- **Undefined Symbols**: `register_ucsi_glink_notifier`, `unregister_ucsi_glink_notifier`
- **Caller Objects**: `fsa4480-i2c.o` (USB-C audio switch)
- **Provider Object**: `drivers/usb/typec/ucsi/ucsi_glink.o`
- **Required Configs**: `CONFIG_TYPEC_UCSI=y` AND `CONFIG_UCSI_QTI_GLINK=y`
- **Root Cause**: We set `CONFIG_UCSI_QTI_GLINK=y`, but Kconfig demoted it to `=m` because parent `CONFIG_TYPEC_UCSI=m` was modular in GKI.
- **Stock Value**: `CONFIG_TYPEC_UCSI=y` AND `CONFIG_UCSI_QTI_GLINK=y` in `stock_defconfig`.

---

### Cluster 4 — USB BAM & DWC3 (Qualcomm USB Bus Access Manager)
- **Undefined Symbols**: `usb_bam_get_bam_type`, `usb_bam_get_connection_idx`, `get_qdss_bam_info`, `usb_bam_disconnect_pipe`, `usb_bam_free_fifos`, `msm_ep_set_endless`
- **Caller Objects**: `u_qdss.o`, `f_qdss.o` (USB QDSS trace)
- **Provider Objects**: `drivers/usb/dwc3/usb_bam.o`, `drivers/usb/dwc3/dbm.o`
- **Required Configs**: `CONFIG_USB_BAM=y` AND `CONFIG_USB_DWC3_MSM=y`
- **Root Cause**: Both `CONFIG_USB_BAM` and `CONFIG_USB_DWC3_MSM` were set to `=m` in `lahaina_GKI.config`.
- **Stock Value**: `CONFIG_USB_BAM=y` AND `CONFIG_USB_DWC3_MSM=y` in `stock_defconfig`.

---

### Cluster 5 — SDHCI Inline Crypto (MMC Storage Encryption)
- **Undefined Symbol**: `cqhci_crypto_qti_set_vops`
- **Caller Object**: `sdhci-msm.o`
- **Provider Object**: `drivers/mmc/host/cqhci-crypto-qti.o`
- **Required Configs**: `CONFIG_MMC_CQHCI=y` AND `CONFIG_MMC_CQHCI_CRYPTO_QTI=y`
- **Root Cause**: We set `CONFIG_MMC_CQHCI_CRYPTO_QTI=y`, but parent `CONFIG_MMC_CQHCI=m` was modular, so Kconfig demoted `CRYPTO_QTI` to `=m`.
- **Stock Value**: `CONFIG_MMC_CQHCI=y` AND `CONFIG_MMC_CQHCI_CRYPTO_QTI=y` in `stock_defconfig`.

---

### Cluster 6 — Display HDCP (High-bandwidth Digital Content Protection)
- **Undefined Symbols**: `msm_hdcp_register`, `msm_hdcp_unregister`
- **Caller Object**: `msm_drv.o` (techpack display driver)
- **Provider Object**: `techpack/display/hdcp/msm_hdcp.o`
- **Required Configs**: `CONFIG_QCOM_QSEECOM=y` AND `CONFIG_HDCP_QSEECOM=y`
- **Root Cause**: We set `CONFIG_HDCP_QSEECOM=y`, but parent `CONFIG_QCOM_QSEECOM=m` was modular, so Kconfig demoted `HDCP_QSEECOM` to `=m`.
- **Stock Value**: `CONFIG_QCOM_QSEECOM=y` AND `CONFIG_HDCP_QSEECOM=y` in `stock_defconfig`.

---

### Cluster 7 — Subsystem Restart (ADSP PIL)
- **Undefined Symbol**: `download_mode_adsp`
- **Caller Object**: `msm_subsystem_restart.o`
- **Provider Object**: `drivers/soc/qcom/pil-q6v5-mss.o` / `pil-q6v5-pas.o`
- **Required Config**: `CONFIG_MSM_PIL_MSS_QDSP6V5=y` (or `CONFIG_MSM_PAS_MSS=y`)
- **Root Cause**: PIL MSS driver was modular in `lahaina_GKI.config`.
- **Stock Value**: `CONFIG_MSM_PIL_MSS_QDSP6V5=y` in `stock_defconfig`.

---

## Summary & Action Plan

To systematically resolve all 7 remaining clusters in a single update, we need to promote these parent subsystem configs to `=y` in `ZS673KS-perf.config`:

```kconfig
# Parent GKI module demotions — restore to built-in (=y)
CONFIG_QCOM_LLCC=y
CONFIG_QCOM_KGSL_IOMMU=y
CONFIG_TYPEC_UCSI=y
CONFIG_USB_BAM=y
CONFIG_USB_DWC3_MSM=y
CONFIG_MMC_CQHCI=y
CONFIG_QCOM_QSEECOM=y
CONFIG_MSM_PIL_MSS_QDSP6V5=y
```
