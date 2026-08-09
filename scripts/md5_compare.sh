#!/bin/bash

OEM_DIR="/mnt/android-build/mnt_oem_vendor"
OUR_DIR="/mnt/android-build/out/target/product/rog5s/obj/PACKAGING/target_files_intermediates/lineage_rog5s-target_files-eng.android-build/VENDOR"

echo "=== MD5 CHECKSUM COMPARISON (Display HALs) ==="
echo ""

# Find all display/graphics related binaries in the OEM vendor
find "$OEM_DIR" -type f \( -name "*display*" -o -name "*graphics*" -o -name "*composer*" -o -name "*gralloc*" -o -name "*mapper*" -o -name "*allocator*" \) | sort | while read oem_file; do
    rel_path="${oem_file#$OEM_DIR/}"
    our_file="$OUR_DIR/$rel_path"
    
    # Calculate OEM MD5
    oem_md5=$(md5sum "$oem_file" | awk '{print $1}')
    
    # Check if file exists in our build
    if [ ! -f "$our_file" ]; then
        echo "MISSING: $rel_path"
        continue
    fi
    
    # Calculate Our MD5
    our_md5=$(md5sum "$our_file" | awk '{print $1}')
    
    if [ "$oem_md5" == "$our_md5" ]; then
        echo "MATCH:    $rel_path"
    else
        echo "MISMATCH: $rel_path"
        echo "   OEM: $oem_md5"
        echo "   OUR: $our_md5"
    fi
done
