#!/bin/bash

VM="$(basename $(pwd))"

for MAC in $(virsh domiflist $VM | grep 52:54 | awk '{ print $5 }')
do
    virsh net-dhcp-leases default | grep $MAC | awk '{ print $5 }' | cut -f 1 -d '/'
done
