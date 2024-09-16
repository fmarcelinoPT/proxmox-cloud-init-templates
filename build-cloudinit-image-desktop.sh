#!/bin/bash

# Variables
VMID=1001 # ID for the new VM
VMNAME="ubuntu-desktop-24-04" # Name of the VM
VENDOR_DATA_PATH="local:snippets/ubuntu-desktop.yaml" # Path to your vendor.yaml file
# Default values
USERNAME="donutuse" # Replace with the desired username
PASSWORD="password" # Replace with the desired password (hashed if possible)
IMG_PATH="/tmp/noble-server-cloudimg-amd64.img" # Path to the downloaded image
STORAGE="local-lvm" # Storage location for VM disk
SSH_KEY_PATH="./onemarc_rsa.pub" # Path to the SSH public key file

# Remove old template
qm stop $VMID && qm unlock $VMID && qm destroy $VMID -destroy-unreferenced-disks 1 -purge 1

# Create a new VM using qm command
qm create $VMID \
  --name $VMNAME \
  --ostype l26 \
  --memory 8192 \
  --cores 4 \
  --net0 virtio,bridge=vmbr0 \
  --agent 1 \
  --scsihw virtio-scsi-pci \
  --vga std # VGA setting suitable for desktop environments

# Import the disk image and set it as the boot disk
qm importdisk $VMID $IMG_PATH $STORAGE
qm set $VMID --scsi0 ${STORAGE}:vm-$VMID-disk-0

# Set cloud-init options (user, password, and ssh key)
qm set $VMID --ide2 ${STORAGE}:cloudinit
qm set $VMID --boot c --bootdisk scsi0
qm set $VMID --ciuser $USERNAME
qm set $VMID --cipassword $(openssl passwd -6 $PASSWORD)
qm set $VMID --sshkeys $SSH_KEY_PATH

# Configure network to use DHCP
qm set $VMID --ipconfig0 ip=dhcp

# Set the vendor-data file to customize the packages (including KDE Plasma Desktop)
qm set $VMID --cicustom "vendor=$VENDOR_DATA_PATH"

# Resize the disk to 64GB for desktop environment
qm resize $VMID scsi0 64G

# Start the VM so Cloud-Init can run and apply the vendor.yaml configurations
qm start $VMID

echo "Waiting for the VM to apply configurations via Cloud-Init..."

# Wait for the VM to shut down, which means it finished processing Cloud-Init
while qm status $VMID | grep -q "running"; do
    sleep 5
done

echo "VM has been shut down. Proceeding to convert it to a template..."

# Convert the VM to a template
qm template $VMID

echo "Template $VMNAME created successfully with VM ID: $VMID"
