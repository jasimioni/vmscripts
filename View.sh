#!/bin/bash

VM="$(basename $(pwd))"

virt-viewer $VM 2>/dev/null &
