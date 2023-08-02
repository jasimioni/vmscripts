#!/bin/bash

VM=$(pwd | sed -e 's/\//-/g' -e 's/^-//' -e 's/^vms-//')
NOW=$(date +"%Y%m%d-%H%M%S")

virsh snapshot-create-as --domain $VM --name $NOW
