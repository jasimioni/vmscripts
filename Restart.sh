#!/bin/bash

VM=$(pwd | sed -e 's/\//-/g' -e 's/^-//' -e 's/^vms-//')

virsh destroy $VM
virsh start $VM
