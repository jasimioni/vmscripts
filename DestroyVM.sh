#!/bin/bash

VM=$(pwd | sed -e 's/\//-/g' -e 's/^-//' -e 's/^vms-//')

if [ $VM == 'vms' ]
then
    echo "Ooops, wrong dir"
    exit
fi

virsh snapshot-list $VM --name | xargs -n 1 virsh snapshot-delete $VM

virsh destroy $VM
virsh undefine $VM --nvram

if [ $1 == '-delete' ]
then
    DIR=$(basename $(pwd))
    cd ..
    rm -rf $DIR
fi
