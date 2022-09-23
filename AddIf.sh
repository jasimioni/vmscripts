#!/bin/bash

MAC=$(printf '52:54:00:%02X:%02X:%02X\n' $[RANDOM%256] $[RANDOM%256] $[RANDOM%256])
virsh attach-interface --domain $1 --type network --source $2 --model virtio --mac $MAC --config --live
