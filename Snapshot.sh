#!/bin/bash

VM="$(basename $(pwd))"
NOW=$(date +"%Y%m%d-%H%M%S")

virsh snapshot-create-as --domain $VM --name $NOW
