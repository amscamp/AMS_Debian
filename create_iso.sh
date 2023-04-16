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

# Extracting the Initrd from an ISO Image

mkdir $current_path/iso
sudo xorriso -osirrox on -indev $CURRISO -extract / $current_path/iso
# sudo chown -R $UUID:$GUID $current_path/iso/


# Adding a Preseed File to the Initrd
sudo chmod +w -R $current_path/iso/install.amd/
sudo gunzip $current_path/iso/install.amd/initrd.gz
sudo echo $current_path/preseed.cfg | cpio -H newc -o -A -F $current_path/iso/install.amd/initrd
sudo gzip $current_path/iso/install.amd/initrd
sudo chmod -w -R $current_path/iso/install.amd/


# Regenerating md5sum.txt

sudo chmod +w $current_path/iso/md5sum.txt
#find -follow -type f ! -name md5sum.txt -print0 | xargs -0 md5sum > md5sum.txt
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
