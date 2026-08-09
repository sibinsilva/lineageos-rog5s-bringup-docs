#!/usr/bin/env bash
# ==============================================================================
# Single-Run Build Script: Build Open-Source Vendor Image for ROG Phone 5s
# Target Device: rog5s (ASUS_I005D / ZS676KS)
# ==============================================================================

set -eo pipefail

BUILD_ROOT="/mnt/android-build"

echo "=========================================================="
echo "🚀 Starting Open-Source Vendor Image Build for ROG 5s..."
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

# Build Vendor Image
echo "🔨 Compiling m vendorimage..."
m vendorimage -j$(nproc)

echo "=========================================================="
echo "✅ Vendor Image Build Completed Successfully!"
echo "📍 Output Location: out/target/product/rog5s/vendor.img"
echo "=========================================================="
