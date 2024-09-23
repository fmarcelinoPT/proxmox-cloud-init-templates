#!/bin/bash

export VMID=1005
export VMID_CLONED=600

# Clone Template to VM
qm clone $VMID $VMID_CLONED --name centos-stream9-test -full -storage local-lvm
qm set $VMID_CLONED --ipconfig0 ip=192.168.8.110/24,gw=192.168.8.1
# qm resize $VMID_CLONED virtio0 +35G
# qm set $VMID_CLONED --core 4 --memory 5120 --balloon 0
qm start $VMID_CLONED
