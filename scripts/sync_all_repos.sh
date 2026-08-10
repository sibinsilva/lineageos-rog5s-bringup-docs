#!/usr/bin/env bash
# ==============================================================================
# Single-Run Repository Status & Sync Script for LineageOS ROG 5 / 5s Trees
# ==============================================================================

set -eo pipefail

BUILD_ROOT="/mnt/android-build"

echo "=========================================================="
echo "📡 Checking Git Status & Syncing All Core Repositories..."
echo "=========================================================="

REPOS=(
    "device/asus/rog5-common"
    "device/asus/rog5s"
    "device/asus/rog5"
    "vendor/asus/rog5s"
    "kernel/asus/sm8350"
    "hardware/qcom-caf/sm8350/display"
)

for REPO in "${REPOS[@]}"; do
    TARGET_PATH="${BUILD_ROOT}/${REPO}"
    if [ -d "${TARGET_PATH}" ]; then
        echo "----------------------------------------------------------"
        echo "📁 Repository: ${REPO}"
        BRANCH=$(git -C "${TARGET_PATH}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "N/A")
        HEAD_HASH=$(git -C "${TARGET_PATH}" rev-parse --short HEAD 2>/dev/null || echo "N/A")
        echo "   Branch: ${BRANCH} | HEAD: ${HEAD_HASH}"
        git -C "${TARGET_PATH}" status -s
    else
        echo "⚠️ Repository directory not found: ${TARGET_PATH}"
    fi
done

echo "=========================================================="
echo "✅ Repository Sync Audit Completed!"
echo "=========================================================="
