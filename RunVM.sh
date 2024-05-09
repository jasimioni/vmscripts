#!/bin/bash

VM=$(pwd | sed -e 's/\//-/g' -e 's/^-//' -e 's/^vms-//')

if [ -f ${VM}-vda.qcow2 ]
then
    if [ "$1" == "-force" ]
    then
        echo "VM already exists - overriding"
    else
        echo "VM already exists - will not override unles -force"
        exit
    fi
fi

MEMORY=8192
VCPUS=4
DISKSIZE=50G
NETWORK=default
IMAGE=jammy
BOOT=hd
TPM=no
UEFI=yes
SECUREBOOT=no
NVME=""
ARCH=amd64
EXTRAPARAMS=""

if [ -f config ]
then
	source config
fi

virsh destroy ${VM}
virsh undefine ${VM} --nvram
rm -f ${VM}-seed.img
rm -f ${VM}-vda.qcow2

if [ $IMAGE == 'empty' ]
then
    qemu-img create -f qcow2 ${VM}-vda.qcow2 $DISKSIZE
else
    if [ $ARCH == 'arm' ]
    then
        qemu-img create -b /vms/images/$IMAGE-server-cloudimg-arm64.img -F qcow2 -f qcow2 ${VM}-vda.qcow2
    else
        qemu-img create -b /vms/images/$IMAGE-server-cloudimg-amd64.img -F qcow2 -f qcow2 ${VM}-vda.qcow2
    fi
    qemu-img resize ${VM}-vda.qcow2 $DISKSIZE

    if [ ! -f user-data ]
    then
	    echo "Creating default user-data"
	    cat > user-data <<EOF
#cloud-config
password: passw0rd
chpasswd: { expire: False }
hostname: ${VM}
package_update: true
ssh_import_id: [jasimioni]
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDEL+gDYGgV3R2zt2CJSA7sCGX6WeyRmXDkV+F+si4/vQkNy2fWTzaFnKwOw4IpXhLlEiDwdTJcl5eeum1zN5ORcamBIW7KXk2bDvL/lKP+y09ERuVUIizdbe0LEWVzo8NlLq+8yhf/fwcniQHD7ysL2T9Az5UaJiaPWW4mBfKKxKbg5wJwePLaMHtqcNlwmHdtqkaFlsyw7sfwNK0QmllSwY0L2Ku/umGwCDKjBQi+a4QwcrzJDa2aovTBaewf0BIcNnYdhWWVotvDnvwyvixAWrpniZQT3gnStU9cegBo3dCQc+yYcRV6x1hNGVLnP68/c2QEHh2+64ZehXo9xT214zO6/2dS6DLH2IJa6kBZAeNtdPm1TgYcMZn1btk77ok+DZi0XV9kiKdgQeet42RcjO7+XB3K2wjRqZLDmxMZBGoiZx0yAaNLic5G4IOFXox5x3jFt3Cvf4WWlSdFDtUP3dH7B9mCGXYdcbk63oDhGs6mcv+soaoHx3Ax6MdFvf8= jasimioni@WSJAS01
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8CZ2zF5S702GLTw5qudE3CXTns+xufERAf6yQgExatyGHp+1Wa3BsXqqFmVTI7lYkF/lYUUYUB1ZYTZdDvag5xO0FknldGy+6h4eS7obwbJS/naoBTOCtnoAkuTLEj39epYyrgjQf+uS47t4HIazOaCm0v5hVRc8eRfQSXkBNCdhHF3vnh6yicXN0C7LfHx6LdlpeaHV+dquML6RZvM2v0fpKfRrOGU6qPV6KVsnaWKJ1ZGmzcUbhk/vrkeohu4dhXEzNfnfCu5Vddg7tu7fEul55yKIEzmCwztcoKyvGvfFfmEFHA4IEFbGm9iHvkSkxvQqEYhHoCaoDEQ683j5JqGu8eCbw1WSjGAey7rQWYVAeulG0XesmrByd4WoHmvE3rOiRovR42mhISULbB145WP3xpptaKfpOKykauzXU3udwr9UCeObsffdgxcg2R0qbP6oubB9Q0Atilz+D++keImd+YkiyzSX5cffHAjv2i6jDHFmfjS6kONEx+uViNcc= ubuntu@labjas02
version: 2
EOF
    fi

    if [ -f network-data ]
    then
	    cloud-localds -d qcow2 --network-config=network-data ${VM}-seed.qcow2 user-data
    else
	    cloud-localds -d qcow2 ${VM}-seed.qcow2 user-data
    fi
fi

if [ "$NVME" != "" ]
then
    seq=1
    for DISKSIZE in $NVME
    do
        qemu-img create -f raw nvme${seq}.img $DISKSIZE
        chmod 666 nvme${seq}.img
        NVMEDISKS="$NVMEDISKS --qemu-commandline='-drive file=$(pwd)/nvme${seq}.img,format=raw,if=none,id=NVME${seq}' --qemu-commandline='-device nvme,drive=NVME${seq},serial=nvme-${seq}'"
        seq=$(($seq + 1))
    done
fi

if [ $ARCH == 'arm' ]
then
    OPTIONS="$OPTIONS --arch aarch64"
fi
if [ $BOOT == 'pxe' ]
then
    OPTIONS="$OPTIONS --pxe"
    BOOT=hd
fi

if [ $UEFI == 'yes' ]
then
    if [ $SECUREBOOT == 'yes' ]
    then
        OPTIONS="$OPTIONS --machine q35 --boot uefi,loader_secure=yes"
    else
        OPTIONS="$OPTIONS --boot uefi"
    fi
fi

if [ $TPM == 'yes' ]
then
    OPTIONS="$OPTIONS --tpm backend.type=emulator,backend.version=2.0,model=tpm-tis"
fi

if [ $IMAGE == 'empty' ]
then
    CMD="virt-install $OPTIONS --osinfo detect=on,require=off --name ${VM} --memory $MEMORY --vcpus $VCPUS --disk=${VM}-vda.qcow2,bus=virtio --network network=$NETWORK,model=virtio --boot $BOOT $NVMEDISKS --noautoconsole"
else
    CMD="virt-install $OPTIONS --osinfo detect=on,require=off --name ${VM} --memory $MEMORY --vcpus $VCPUS --disk=${VM}-vda.qcow2,bus=virtio --disk=${VM}-seed.qcow2,bus=sata --network network=$NETWORK,model=virtio --boot $BOOT $NVMEDISKS --noautoconsole"
fi

if [ "$EXTRAPARAMS" != "" ]
then
    OPTIONS="$OPTIONS $EXTRAPARAMS"
fi

if [ "$EXTRADISKS" != "" ]
then
    DISK=b
    for DISKSIZE in $EXTRADISKS
    do
        echo "Creating disk with $DISKSIZE size"
        DISKNAME=${VM}-vd${DISK}.qcow2
        rm -f $DISKNAME
        qemu-img create -f qcow2 $DISKNAME $DISKSIZE
        # virsh attach-disk ${VM} --source $(pwd)/${DISKNAME} --target vd${DISK} --persistent --subdriver qcow2
        CMD="$CMD --disk=${VM}-vd${DISK}.qcow2,bus=virtio"
        DISK=$(echo "$DISK" | tr "0-9a-z" "1-9a-z_")
    done
fi

echo $CMD | tee virt-install-cmd
bash virt-install-cmd

