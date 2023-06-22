#!/bin/bash

#set error
#set -e

echo "In Target script: unmount /dev/shm"
umount /dev/shm
status=$?
[ $status -eq 0 ] && echo "command successful" || echo "command unsuccessful"
echo "In Target script: restore fstab"
cp -rf /etc/fstabbackup /etc/fstab
status=$?
[ $status -eq 0 ] && echo "command successful" || echo "command unsuccessful"
echo "In Target script: remove temporary /dev/shm folder"
rm -rf /dev/shm
status=$?
[ $status -eq 0 ] && echo "command successful" || echo "command unsuccessful"
echo "In Target script: remove fstab backup"
rm -rf /etc/fstabbackup
status=$?
[ $status -eq 0 ] && echo "command successful" || echo "command unsuccessful"

exit 111