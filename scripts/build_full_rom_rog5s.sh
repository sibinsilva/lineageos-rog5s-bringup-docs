#!/usr/bin/env bash
# ==============================================================================
# Single-Run Build Script: Build Full LineageOS 20.0 ROM Zip for ROG Phone 5s
# Target Device: rog5s (ASUS_I005D / ZS676KS)
# ==============================================================================

set -eo pipefail

BUILD_ROOT="/mnt/android-build"

echo "=========================================================="
echo "🚀 Starting Full LineageOS 20.0 ROM Build for ROG 5s..."
echo "=========================================================="

cd "${BUILD_ROOT}"

# Export Build & Ccache Environment
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
export CCACHE_DIR="${HOME}/.ccache"
export CCACHE_MAXSIZE=50G

# Initialize Android Build Environment
source build/envsetup.sh

# Select Lunch Target
lunch lineage_rog5s-userdebug

# Build Full ROM Zip
echo "🔨 Compiling bacon (Full LineageOS Zip)..."
m bacon -j$(nproc)

echo "=========================================================="
echo "🎉 Full LineageOS ROM Build Completed Successfully!"
echo "📍 ROM Zip Location: out/target/product/rog5s/lineage-20.0-*.zip"
echo "=========================================================="
