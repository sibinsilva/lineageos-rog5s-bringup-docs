# 📓 ROG Phone 5 & 5s LineageOS 20.0 Bringup Technical Journal

Welcome to the comprehensive technical bringup journal for **ASUS ROG Phone 5 (`rog5` / `ZS673KS`)** and **ROG Phone 5s (`rog5s` / `ZS676KS`)** on LineageOS 20.0 (Android 13 / Qualcomm SM8350).

This directory documents the step-by-step technical journey, architectural decisions, issues encountered, root causes, and empirical rectifications implemented throughout the bringup process.

---

## 📑 Journal Directory Structure

1. **[`01_BRINGUP_MILESTONES_AND_ARCHITECTURE.md`](./01_BRINGUP_MILESTONES_AND_ARCHITECTURE.md):**  
   Chronological breakdown of bringup phases, tree refactoring into `rog5-common`, kernel integration, and open-source display HAL migration.

2. **[`02_TECHNICAL_ISSUES_AND_RECTIFICATIONS.md`](./02_TECHNICAL_ISSUES_AND_RECTIFICATIONS.md):**  
   Detailed case studies of all technical bugs encountered (AVB hash mismatches, display HAL conflicts, CamX crashes, legacy Zenfone 8 remnants, Soong gating errors) and their exact fixes.

3. **[`03_SECURITY_AND_STANDARDIZATION_AUDIT.md`](./03_SECURITY_AND_STANDARDIZATION_AUDIT.md):**  
   Audit of LineageOS code standards, multi-device naming conventions, and security sanitization (0 secrets/keys committed).

4. **[`04_STEP_BY_STEP_LINEAGE_BRINGUP_WORKFLOW.md`](./04_STEP_BY_STEP_LINEAGE_BRINGUP_WORKFLOW.md):**  
   Step-by-step master bringup workflow detailing Phases 1 through 8 from stock firmware extraction to official commonization release.

---

## 🛡️ Privacy & Security Compliance
* **Zero Credentials:** All personal access tokens, private keys (`.pem`), passwords, and hashes have been excluded or sanitized.
* **No Raw Logs:** Contains structured technical case studies, root causes, and diffs rather than raw conversation logs.
