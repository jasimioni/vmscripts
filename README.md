# vmscripts

This scripts expect a folder /vms/images/ which holds the cloud image files:

```
bionic-server-cloudimg-amd64.img
focal-server-cloudimg-amd64.img
focaldhclient-server-cloudimg-amd64.img
jammy-server-cloudimg-amd64.img
trusty-server-cloudimg-amd64.img
xenial-server-cloudimg-amd64.img
```

Then, just create a folder (that will be the vm name) and optionally add one config file (or defaults will be used).

RunVM.sh runs the VM (edit it since it creates vms with my SSH key on it - change to yours).
GetIP.sh get the IP (if using default network)
Connect.sh connectes to the VM IP ignoring SSH messages

Sample Config:
--------------
```
MEMORY=8096
VCPUS=4
DISKSIZE=20G
NETWORK=nbmaas
IMAGE=empty
BOOT=network,hd
EXTRADISKS="80G 80G 80G 80G"
```

Default Config:
---------------
```
MEMORY=8096
VCPUS=4
DISKSIZE=50G
NETWORK=default
IMAGE=focal
BOOT=hd
TPM=no
```

Hints:
------
Fix nested virtualization in Focal Guests
```
  <cpu mode='host-model' check='partial'/>
```

