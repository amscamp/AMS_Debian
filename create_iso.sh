#!/bin/bash

#set error
set -e


# Install prereqs
sudo apt-get update && sudo apt-get install xorriso libarchive-tools -y

# Make sure relative paths work
cd $(dirname $0)

# set variables
current_path=$(pwd)
orig_iso=$current_path/$CURRISO
new_files=$current_path/iso
mbr_template=$current_path/isohdpfx.bin
CURRISO=$(curl -s https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS |awk -F ' ' '{print $2}' | grep 'debian-[0-9]*\.[0-9]*\.[0-9]*\-amd64-netinst.iso')
CURRVER=$(echo $CURRISO | sed 's|debian-||g' | sed 's|-amd64-netinst.iso||g')
# Download Debian netinstaller
echo $CURRISO
wget --quiet https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/$CURRISO


# See https://wiki.debian.org/DebianInstaller/Preseed/EditIso

# Extracting the Initrd from an ISO Image

sudo mkdir /mnt/iso
sudo mount -o loop $CURRISO /mnt/iso
sudo ls -la /mnt/iso
mkdir $current_path/iso
sudo cp -rf /mnt/iso/* $current_path/iso/


ls -la $current_path/iso/
ls -la iso/
# Adding a Preseed File to the Initrd
chmod +w -R iso/install.amd/
gunzip iso/install.amd/initrd.gz
echo preseed.cfg | cpio -H newc -o -A -F iso/install.amd/initrd
gzip iso/install.amd/initrd
chmod -w -R iso/install.amd/


# Regenerating md5sum.txt
cd iso
chmod +w md5sum.txt
find -follow -type f ! -name md5sum.txt -print0 | xargs -0 md5sum > md5sum.txt
chmod -w md5sum.txt
cd ..


# See https://wiki.debian.org/RepackBootableISO
# Repack as EFI based bootable ISO

# Extract MBR template file to disk
dd if="$orig_iso" bs=1 count=432 of="$mbr_template"

# Run modified contents of file iso/.disk/mkisofs
xorriso -as mkisofs \
   -V "Debian $CURRVER amd64 n" \
   -o debian-$CURRVER-amd64-modified.iso \
   -J -joliet-long -cache-inodes \
   -isohybrid-mbr "$mbr_template" \
   -b isolinux/isolinux.bin \
   -c isolinux/boot.cat \
   -boot-load-size 4 -boot-info-table -no-emul-boot \
   -eltorito-alt-boot \
   -e boot/grub/efi.img \
   -no-emul-boot \
   -isohybrid-gpt-basdat \
   -isohybrid-apm-hfsplus \
   "$new_files"
