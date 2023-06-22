#!/bin/bash

#set error
#set -e


echo "In Target script: run ansible pull"
/bin/ansible-pull -vvv -d /ansibleconfig -i /ansibleconfig/inventory -U https://github.com/amscamp/AMS_Debian_Ansible -C $1
status=$?
[ $status -eq 0 ] && echo "command successful" || echo "command unsuccessful"
