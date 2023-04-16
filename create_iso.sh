#!/bin/bash

#set error
set -e


# Install prereqs
sudo apt-get update && sudo apt-get install xorriso libarchive-tools -y

# Make sure relative paths work
cd $(dirname $0)

# set variables
current_path=$(pwd)
GUID=$(id --group)
UUID=$(id --user)
new_files=$current_path/iso
mbr_template=$current_path/isohdpfx.bin
CURRISO=$(curl -s https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS |awk -F ' ' '{print $2}' | grep 'debian-[0-9]*\.[0-9]*\.[0-9]*\-amd64-netinst.iso')
CURRVER=$(echo $CURRISO | sed 's|debian-||g' | sed 's|-amd64-netinst.iso||g')
orig_iso=$current_path/$CURRISO
# Download Debian netinstaller
echo $CURRISO
wget --quiet https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/$CURRISO


# See https://wiki.debian.org/DebianInstaller/Preseed/EditIso

# Extracting the ISO Image

mkdir $current_path/iso
sudo xorriso -osirrox on -indev $CURRISO -extract / $current_path/iso

# Change isolinux for autosetup and preseed

sudo sed -i 's|default.*|default auto|g' $current_path/iso/isolinux/isolinux.cfg
sudo sed -i 's|auto=true|& url=http://raw.githubusercontent.com/amscamp/AMS_Debian/main/preseed.cfg|' $current_path/iso/isolinux/adtxt.cfg

# Regenerating md5sum.txt
sudo chmod +w $current_path/iso/md5sum.txt
sudo sh -c "cd $current_path/iso && find -follow -type f ! -name md5sum.txt -print0 | xargs -0 md5sum > md5sum.txt"
sudo chmod -w $current_path/iso/md5sum.txt 
cat $current_path/iso/md5sum.txt | wc -l


# See https://wiki.debian.org/RepackBootableISO
# Repack as EFI based bootable ISO

# Extract MBR template file to disk
sudo dd if="$orig_iso" bs=1 count=432 of="$mbr_template"

# Run modified contents of file iso/.disk/mkisofs
sudo xorriso -as mkisofs \
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
