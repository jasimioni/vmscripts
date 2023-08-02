#!/bin/bash

VM=$(pwd | sed -e 's/\//-/g' -e 's/^-//' -e 's/^vms-//')

for MAC in $(virsh domiflist $VM | grep 52:54 | awk '{ print $5 }')
do
    IP=$(virsh net-dhcp-leases default | grep $MAC | awk '{ print $5 }' | cut -f 1 -d '/')
    if [ $IP != "" ]
    then
            ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" $IP
            break
    fi
done
