#!/bin/bash

#set error
#set -e

#ansible prereqs
echo "In Target script: install ansible role community general"
ansible-galaxy collection install community.general
status=$?
[ $status -eq 0 ] && echo "command successful" || echo "command unsuccessful"

#ansible /dev/shm fix
echo "In Target script: create temporary /dev/shm folder"
mkdir /dev/shm 
status=$?
[ $status -eq 0 ] && echo "command successful" || echo "command unsuccessful"
echo "In Target script: set permissions on temporary /dev/shm folder"
chmod 777 /dev/shm
status=$?
[ $status -eq 0 ] && echo "command successful" || echo "command unsuccessful"
echo "In Target script: backup fstab"
cp /etc/fstab /etc/fstabbackup
status=$?
[ $status -eq 0 ] && echo "command successful" || echo "command unsuccessful"
echo "In Target script: add /dev/shm to fstab"
echo 'none /dev/shm tmpfs rw,nosuid,nodev,noexec 0 0' >> /etc/fstab
status=$?
[ $status -eq 0 ] && echo "command successful" || echo "command unsuccessful"
echo "In Target script: mount /dev/shm"
mount /dev/shm
status=$?
[ $status -eq 0 ] && echo "command successful" || echo "command unsuccessful"

#ansibleconfig folder
echo "In Target script: create /ansibleconfig folder"
mkdir /ansibleconfig
status=$?
[ $status -eq 0 ] && echo "command successful" || echo "command unsuccessful"
