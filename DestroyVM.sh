#!/bin/bash

VM="$(basename $(pwd))"

if [ $VM == 'vms' ]
then
    echo "Ooops, wrong dir"
    exit
fi

virsh snapshot-list $VM --name | xargs -n 1 virsh snapshot-delete $VM

virsh destroy $VM
virsh undefine $VM
