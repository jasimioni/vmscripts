#!/bin/bash

VM=$(pwd | sed -e 's/\//-/g' -e 's/^-//' -e 's/^vms-//')

virt-viewer $VM 2>/dev/null &
