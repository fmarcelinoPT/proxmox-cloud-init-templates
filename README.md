# Proxmox Cloud-Init Image Builder

This project contains two shell scripts, `build-cloudinit-image-desktop.sh` and `build-cloudinit-image-server.sh`, which are used to create Proxmox Virtual Environment (PVE) templates for Ubuntu Desktop and Server, respectively.

These templates are configured with Cloud-Init to automatically set up the operating system during the first boot.

## Table of Contents

- [Installation](#installation)
- [Preparation](#preparation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Installation

1. Clone the repository to your local machine.
2. Make sure you have the necessary permissions to run the scripts and interact with Proxmox Virtual Environment.
3. Install any dependencies required by the scripts.

## Preparation

### SSH Keys

Create the ssh keys according to [My Freakin Homelab > SSH-Keys](https://github.com/fmarcelinoPT/my-freakin-homelab/tree/main/ssh-keys#readme).

### Creating the vendor.yaml file for cloudinit

First, ensure that the `local` storage is setup to store `snippets`.

Then create the `snippets`:

```bash
cat << EOF | tee /var/lib/vz/snippets/ubuntu-server.yaml
#cloud-config
apt:
  primary:
    - arches: [default]
      uri: http://pt.archive.ubuntu.com/ubuntu/

package_update: true

package_upgrade: true

locale: pt_PT

runcmd:
  - useradd -m -d /home/ansiblebot -s /bin/bash ansiblebot
  - echo "ansiblebot:password" | chpasswd
  - mkdir /home/ansiblebot/.ssh
  - touch /home/ansiblebot/.ssh/authorized_keys
  - chown -R ansiblebot:ansiblebot /home/ansiblebot/.ssh
  - chmod 700 /home/ansiblebot/.ssh
  - chmod 600 /home/ansiblebot/.ssh/authorized_keys
  - |
    echo "ansiblebot ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ansiblebot
  - echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWDAlsCB5kRfoYW1jnd0/9kmZtalmN4cM8T5qJ8ualsMVTwo22ijKwieQG5yRpvgWAb87tBpoTtx+moKk7DIWezkyAAn5ptzHDeupyXith3otLtm8gy6uSvHJWrd3K24pnsjCuHAvlKmqtpC2IiPM0EoHsQLljiOPsSfJ4I8IBCrNMXOZI1tAzTIJB3GIsLk1D6E6/rwSWwqif87mQlqFV2dv3F0qpBN1ZPNldNCor2FD7RWmJsIGmGFadoIW/G/MXDlHnKqQQtPCytQNF2Q8JLf4eSytZRhcqrkOM3DmZ2hItM3JxbGB7NfUWS6gN9CzamE5Xumb2MxHQMqQrvJaKggsWTNecioDL1nm5FKfgbKMOoKpKkkw3ng0npay+rnpWcLceX3u9de49qEi68P6o/aF4MjdtXODFyT9lr6dmd51/7TYkmSlmIbcVsZi6rN9VvO7pOwy3tw4bPBj0IYX1OsDv1OTKPzKWPtTCY3Fa485vSRJP8y77OxlgzTSjhmskrWQNXd3rftjbuvWzg8uCVhh0edbo3TU5+z6dcMszkU1m7nPeyYp2pOcamKyXkOAgamfrqvOzPVun1OEwpc/5b7mSPufnGREj35RTWqYAFDpZ3BeUaHOKRwoUSsMNuoNPeaR723YZVhduaAUKZdnycHffduRWsp7S723AMWyaLw== support_pub_key" >> /home/ansible/.ssh/authorized_keys
  - apt install -y qemu-guest-agent
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - loadkeys pt
EOF
```

```bash
cat << EOF | tee /var/lib/vz/snippets/ubuntu-desktop.yaml
#cloud-config
apt:
  primary:
    - arches: [default]
      uri: http://pt.archive.ubuntu.com/ubuntu/

package_update: true

package_upgrade: true

locale: pt_PT

write_files:
  - path: /etc/lightdm/lightdm.conf
    content: |
      [Seat:*]
      autologin-user-timeout=0
      user-session=plasma

runcmd:
  - useradd -m -d /home/ansiblebot -s /bin/bash ansiblebot
  - echo "ansiblebot:password" | chpasswd
  - mkdir /home/ansiblebot/.ssh
  - touch /home/ansiblebot/.ssh/authorized_keys
  - chown -R ansiblebot:ansiblebot /home/ansiblebot/.ssh
  - chmod 700 /home/ansiblebot/.ssh
  - chmod 600 /home/ansiblebot/.ssh/authorized_keys
  - |
    echo "ansiblebot ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ansiblebot
  - echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWDAlsCB5kRfoYW1jnd0/9kmZtalmN4cM8T5qJ8ualsMVTwo22ijKwieQG5yRpvgWAb87tBpoTtx+moKk7DIWezkyAAn5ptzHDeupyXith3otLtm8gy6uSvHJWrd3K24pnsjCuHAvlKmqtpC2IiPM0EoHsQLljiOPsSfJ4I8IBCrNMXOZI1tAzTIJB3GIsLk1D6E6/rwSWwqif87mQlqFV2dv3F0qpBN1ZPNldNCor2FD7RWmJsIGmGFadoIW/G/MXDlHnKqQQtPCytQNF2Q8JLf4eSytZRhcqrkOM3DmZ2hItM3JxbGB7NfUWS6gN9CzamE5Xumb2MxHQMqQrvJaKggsWTNecioDL1nm5FKfgbKMOoKpKkkw3ng0npay+rnpWcLceX3u9de49qEi68P6o/aF4MjdtXODFyT9lr6dmd51/7TYkmSlmIbcVsZi6rN9VvO7pOwy3tw4bPBj0IYX1OsDv1OTKPzKWPtTCY3Fa485vSRJP8y77OxlgzTSjhmskrWQNXd3rftjbuvWzg8uCVhh0edbo3TU5+z6dcMszkU1m7nPeyYp2pOcamKyXkOAgamfrqvOzPVun1OEwpc/5b7mSPufnGREj35RTWqYAFDpZ3BeUaHOKRwoUSsMNuoNPeaR723YZVhduaAUKZdnycHffduRWsp7S723AMWyaLw== support_pub_key" >> /home/ansible/.ssh/authorized_keys
  - apt install -y qemu-guest-agent
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - apt install -y lightdm
  - systemctl enable lightdm
  - systemctl start lightdm
  - apt install -y plasma-desktop
  - apt install -y konsole
  - apt remove -y vim
  - apt autoremove
  - loadkeys pt
EOF
```

```bash
cat << EOF | tee /var/lib/vz/snippets/centos-server.yaml
#cloud-config
package_update: true

package_upgrade: true

locale: pt_PT

runcmd:
  - yum install -y vim git net-tools
  - useradd -m -d /home/ansiblebot -s /bin/bash ansiblebot
  - echo "ansiblebot:password" | chpasswd
  - mkdir /home/ansiblebot/.ssh
  - touch /home/ansiblebot/.ssh/authorized_keys
  - chown -R ansiblebot:ansiblebot /home/ansiblebot/.ssh
  - chmod 700 /home/ansiblebot/.ssh
  - chmod 600 /home/ansiblebot/.ssh/authorized_keys
  - |
    echo "ansiblebot ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/ansiblebot
  - echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWDAlsCB5kRfoYW1jnd0/9kmZtalmN4cM8T5qJ8ualsMVTwo22ijKwieQG5yRpvgWAb87tBpoTtx+moKk7DIWezkyAAn5ptzHDeupyXith3otLtm8gy6uSvHJWrd3K24pnsjCuHAvlKmqtpC2IiPM0EoHsQLljiOPsSfJ4I8IBCrNMXOZI1tAzTIJB3GIsLk1D6E6/rwSWwqif87mQlqFV2dv3F0qpBN1ZPNldNCor2FD7RWmJsIGmGFadoIW/G/MXDlHnKqQQtPCytQNF2Q8JLf4eSytZRhcqrkOM3DmZ2hItM3JxbGB7NfUWS6gN9CzamE5Xumb2MxHQMqQrvJaKggsWTNecioDL1nm5FKfgbKMOoKpKkkw3ng0npay+rnpWcLceX3u9de49qEi68P6o/aF4MjdtXODFyT9lr6dmd51/7TYkmSlmIbcVsZi6rN9VvO7pOwy3tw4bPBj0IYX1OsDv1OTKPzKWPtTCY3Fa485vSRJP8y77OxlgzTSjhmskrWQNXd3rftjbuvWzg8uCVhh0edbo3TU5+z6dcMszkU1m7nPeyYp2pOcamKyXkOAgamfrqvOzPVun1OEwpc/5b7mSPufnGREj35RTWqYAFDpZ3BeUaHOKRwoUSsMNuoNPeaR723YZVhduaAUKZdnycHffduRWsp7S723AMWyaLw== support_pub_key" >> /home/ansible/.ssh/authorized_keys
  - yum clean all
  - rm -rf /var/cache/yum
EOF
```

This files serves two purposes: the first one is quite evident (installing `qemu-guest-agent`), while the second purpose may not be as obvious. Due to the sequencing of CloudInit, it initiates after networking, resulting in the inability to SSH or even ping the VM using the assigned name. However, this package is executed only once, so following the reboot, you will have full accessibility to the VM.

Before start creating the image, open `datacenter → storage → select local → add snippets` to contents list:

![Datacenter -> Storage -> Local](proxmox-noble-server-cloudimg/6xdsxi3s.png)

![Added Snippets to Content](proxmox-noble-server-cloudimg/laa4mrso.png)

## Configuration

The scripts use the following configuration files:

- `ubuntu-desktop.yaml`
- `ubuntu-server.yaml`
- `centos-server.yaml`

Which are used by Cloud-Init to customize the packages installed on the operating system. These files should be registered on the PVE and stored in the `local:snippets/` directory.

The `ubuntu-desktop.yaml` file is used in the `build-cloudinit-image-ubuntu-noble-desktop.sh` script to install the KDE Plasma Desktop environment.

## Usage

Download the needed images:

```bash
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
wget https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-x86_64-9-latest.x86_64.qcow2
```

To create a new template, run the appropriate script in a PVE node:

- For Ubuntu Desktop:

```bash
sh build-cloudinit-image-ubuntu-noble-desktop.sh
```

- For Ubuntu Server:

```bash
sh build-cloudinit-image-ubuntu-noble-server.sh
```

- For CentOS:

```bash
sh build-cloudinit-image-centos-stream9.sh
```

These scripts will create a new virtual machine, configure it with Cloud-Init, and then convert it into a template. The template can then be used to quickly create new virtual machines with the same configuration.

## Build cloudinit image

Login to a PVE node and ensure that the following files exists on the running folder:

```bash
onemarc_rsa
onemarc_rsa.pub
support_rsa
support_rsa.pub
download-images.sh
build-cloudinit-image-ubuntu-noble-server.sh
build-cloudinit-image-ubuntu-noble-desktop.sh
build-cloudinit-image-centos-stream9.sh
cleanup-working-files.sh
```

And you created the `vendor.yaml` files.

Run this commands:

```bash
sh download-images.sh
sh build-cloudinit-image-ubuntu-noble-server.sh
sh build-cloudinit-image-ubuntu-noble-desktop.sh
sh build-cloudinit-image-centos-stream9.sh
sh cleanup-working-files.sh
```

Check cloud-init status:

```bash
cloud-init status --wait
```

Repeat cloud-init:

```bash
cloud-init clean --logs
cloud-init init --local
cloud-init init
cloud-init modules --mode=config
cloud-init modules --mode=final
cloud-init status --wait --long
```

## Test VM creation

```bash
sh create-vm-cloned-ubuntu-noble-server.sh
sh create-vm-cloned-ubuntu-noble-desktop.sh
```

## Desktop tweaks

Change theme on target Ubuntu Desktop: `lookandfeeltool -a org.kde.breezedark.desktop`

## SSH fixes

Need to set right permissions to ssh key:

```bash
cp ./onemarc_rsa ~/.ssh/onemarc_rsa
cp ./onemarc_rsa.pub ~/.ssh/onemarc_rsa.pub
cp ./support_rsa ~/.ssh/support_rsa
cp ./support_rsa.pub ~/.ssh/support_rsa.pub
chmod 400 ./onemarc_rsa
chmod 400 ./onemarc_rsa.pub
chmod 400 ./support_rsa
chmod 400 ./support_rsa.pub
```

## Cleanup

```bash
qm stop 1000 && qm unlock 1000 && qm destroy 1000 -destroy-unreferenced-disks 1 -purge 1
qm stop 1001 && qm unlock 1001 && qm destroy 1001 -destroy-unreferenced-disks 1 -purge 1
qm stop 1002 && qm unlock 1002 && qm destroy 1002 -destroy-unreferenced-disks 1 -purge 1
```

<!--
donutuse
password
-->

## Contributing

Contributions to this project are welcome. If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.

## License

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Author Information

This role was created at 2024 by [fmarcelinoPT](https://github.com/fmarcelinoPT). Feel free to customize or extend the role to fit your needs.

## Resources

- Resources: <https://akashrajvanshi.medium.com/step-by-step-guide-creating-a-ready-to-use-ubuntu-cloud-image-on-proxmox-03d057f04fb2>
