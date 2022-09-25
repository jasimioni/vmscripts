#!/bin/bash

VM="$(basename $(pwd))"

virsh destroy $VM
virsh start $VM
