#!/bin/bash

echo "=== COMMAND 1: Unpack boot.img ==="
mkdir -p /tmp/boot_unpack && cd /tmp/boot_unpack && python3 /mnt/rog5s-build/rog5s_los13/out/host/linux-x86/bin/unpack_bootimg --boot_img /mnt/rog5s-build/rog5s_los13/out/target/product/ZS676KS/boot.img --out /tmp/boot_unpack 2>&1

echo "=== COMMAND 2: Unpack vendor_boot.img ==="
mkdir -p /tmp/vendor_boot_unpack && cd /tmp/vendor_boot_unpack && python3 /mnt/rog5s-build/rog5s_los13/out/host/linux-x86/bin/unpack_bootimg --boot_img /mnt/rog5s-build/rog5s_los13/out/target/product/ZS676KS/obj/PACKAGING/target_files_intermediates/lineage_ZS676KS-target_files-eng.sibindev9746_gmail_com/IMAGES/vendor_boot.img --out /tmp/vendor_boot_unpack 2>&1

echo "=== COMMAND 3: avbtool info_image on boot.img ==="
python3 /mnt/rog5s-build/rog5s_los13/external/avb/avbtool.py info_image --image /mnt/rog5s-build/rog5s_los13/out/target/product/ZS676KS/obj/PACKAGING/target_files_intermediates/lineage_ZS676KS-target_files-eng.sibindev9746_gmail_com/IMAGES/boot.img 2>&1

echo "=== COMMAND 4: avbtool info_image on vendor_boot.img ==="
python3 /mnt/rog5s-build/rog5s_los13/external/avb/avbtool.py info_image --image /mnt/rog5s-build/rog5s_los13/out/target/product/ZS676KS/obj/PACKAGING/target_files_intermediates/lineage_ZS676KS-target_files-eng.sibindev9746_gmail_com/IMAGES/vendor_boot.img 2>&1

echo "=== COMMAND 5: avbtool info_image on vbmeta.img ==="
python3 /mnt/rog5s-build/rog5s_los13/external/avb/avbtool.py info_image --image /mnt/rog5s-build/rog5s_los13/out/target/product/ZS676KS/obj/PACKAGING/target_files_intermediates/lineage_ZS676KS-target_files-eng.sibindev9746_gmail_com/IMAGES/vbmeta.img 2>&1

echo "=== COMMAND 6: Check stock prebuilts ==="
ls -la /mnt/rog5s-build/rog5s_los13/device/asus/ZS676KS/prebuilts/ 2>/dev/null
ls -la /mnt/rog5s-build/twrp/device/asus/ASUS_I005_1/prebuilts/ 2>/dev/null
ls -la /mnt/rog5s-build/twrp/device/asus/sm8350-common/prebuilt/ 2>/dev/null

echo "=== COMMAND 7: Unpack stock boot.img if exists ==="
for stockboot in /mnt/rog5s-build/rog5s_los13/device/asus/ZS676KS/prebuilts/boot.img /mnt/rog5s-build/twrp/device/asus/ASUS_I005_1/prebuilts/boot.img; do if [ -f "$stockboot" ]; then echo "=== STOCK: $stockboot ==="; mkdir -p /tmp/stock_boot_unpack && python3 /mnt/rog5s-build/rog5s_los13/out/host/linux-x86/bin/unpack_bootimg --boot_img "$stockboot" --out /tmp/stock_boot_unpack 2>&1; fi; done

echo "=== COMMAND 8: List extracted files ==="
echo '=== BOOT ===' && ls -la /tmp/boot_unpack/ && echo '=== VENDOR_BOOT ===' && ls -la /tmp/vendor_boot_unpack/
