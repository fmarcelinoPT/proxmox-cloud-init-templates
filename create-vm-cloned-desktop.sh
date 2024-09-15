#!/bin/bash

export VMID=1001
export VMID_CLONED=500

# Clone Template to VM
qm clone $VMID $VMID_CLONED --name ubuntu-desktop-2404-test -full -storage local-lvm
qm set $VMID_CLONED --ipconfig0 ip=192.168.8.112/24,gw=192.168.8.1
# qm resize $VMID_CLONED virtio0 +35G
# qm set $VMID_CLONED --core 4 --memory 5120 --balloon 0
qm start $VMID_CLONED
