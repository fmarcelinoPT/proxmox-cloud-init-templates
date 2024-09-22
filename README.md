# Proxmox Cloud-Init Image Builder

This project contains two shell scripts, `build-cloudinit-image-desktop.sh` and `build-cloudinit-image-server.sh`, which are used to create Proxmox Virtual Environment (PVE) templates for Ubuntu Desktop and Server, respectively.

These templates are configured with Cloud-Init to automatically set up the operating system during the first boot.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [License](#license)

## Installation

1. Clone the repository to your local machine.
2. Make sure you have the necessary permissions to run the scripts and interact with Proxmox Virtual Environment.
3. Install any dependencies required by the scripts.

## Usage

Download the needed images:

```bash
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
wget https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-x86_64-9-latest.x86_64.qcow2
```

To create a new template, run the appropriate script in a PVE node:

- For Ubuntu Desktop:

```bash
./build-cloudinit-image-desktop.sh
```

- For Ubuntu Server:

```bash
./build-cloudinit-image-server.sh
```

These scripts will create a new virtual machine, configure it with Cloud-Init, and then convert it into a template. The template can then be used to quickly create new virtual machines with the same configuration.

## Configuration

The scripts use the following configuration files:

- `ubuntu-desktop.yaml`
- `ubuntu-server.yaml`
- `centos-server.yaml`

Which are used by Cloud-Init to customize the packages installed on the operating system. These files should be registered on the PVE and stored in the `local:snippets/` directory.

The `ubuntu-desktop.yaml` file is used in the `build-cloudinit-image-desktop.sh` script to install the KDE Plasma Desktop environment.

## Contributing

Contributions to this project are welcome. If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.

## Resources

- Resources: <https://akashrajvanshi.medium.com/step-by-step-guide-creating-a-ready-to-use-ubuntu-cloud-image-on-proxmox-03d057f04fb2>

## Preparation

### SSH Keys

Create the ssh keys according to [My Freakin Homelab > SSH-Keys]()

### Creating the vendor.yaml file for cloudinit

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
  - sudo useradd -m -s /bin/bash ansible
  - echo "ansible:password" | chpasswd
  - usermod -aG sudo ansible
  - mkdir -p /home/ansible/.ssh
  - echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWDAlsCB5kRfoYW1jnd0/9kmZtalmN4cM8T5qJ8ualsMVTwo22ijKwieQG5yRpvgWAb87tBpoTtx+moKk7DIWezkyAAn5ptzHDeupyXith3otLtm8gy6uSvHJWrd3K24pnsjCuHAvlKmqtpC2IiPM0EoHsQLljiOPsSfJ4I8IBCrNMXOZI1tAzTIJB3GIsLk1D6E6/rwSWwqif87mQlqFV2dv3F0qpBN1ZPNldNCor2FD7RWmJsIGmGFadoIW/G/MXDlHnKqQQtPCytQNF2Q8JLf4eSytZRhcqrkOM3DmZ2hItM3JxbGB7NfUWS6gN9CzamE5Xumb2MxHQMqQrvJaKggsWTNecioDL1nm5FKfgbKMOoKpKkkw3ng0npay+rnpWcLceX3u9de49qEi68P6o/aF4MjdtXODFyT9lr6dmd51/7TYkmSlmIbcVsZi6rN9VvO7pOwy3tw4bPBj0IYX1OsDv1OTKPzKWPtTCY3Fa485vSRJP8y77OxlgzTSjhmskrWQNXd3rftjbuvWzg8uCVhh0edbo3TU5+z6dcMszkU1m7nPeyYp2pOcamKyXkOAgamfrqvOzPVun1OEwpc/5b7mSPufnGREj35RTWqYAFDpZ3BeUaHOKRwoUSsMNuoNPeaR723YZVhduaAUKZdnycHffduRWsp7S723AMWyaLw== support_pub_key" >> /home/ansible/.ssh/authorized_keys
  - chown -R ansible:ansible /home/ansible/.ssh
  - chmod 700 /home/ansible/.ssh
  - chmod 600 /home/ansible/.ssh/authorized_keys
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
  - sudo useradd -m -s /bin/bash ansible
  - echo "ansible:password" | chpasswd
  - usermod -aG sudo ansible
  - mkdir -p /home/ansible/.ssh
  - echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDWDAlsCB5kRfoYW1jnd0/9kmZtalmN4cM8T5qJ8ualsMVTwo22ijKwieQG5yRpvgWAb87tBpoTtx+moKk7DIWezkyAAn5ptzHDeupyXith3otLtm8gy6uSvHJWrd3K24pnsjCuHAvlKmqtpC2IiPM0EoHsQLljiOPsSfJ4I8IBCrNMXOZI1tAzTIJB3GIsLk1D6E6/rwSWwqif87mQlqFV2dv3F0qpBN1ZPNldNCor2FD7RWmJsIGmGFadoIW/G/MXDlHnKqQQtPCytQNF2Q8JLf4eSytZRhcqrkOM3DmZ2hItM3JxbGB7NfUWS6gN9CzamE5Xumb2MxHQMqQrvJaKggsWTNecioDL1nm5FKfgbKMOoKpKkkw3ng0npay+rnpWcLceX3u9de49qEi68P6o/aF4MjdtXODFyT9lr6dmd51/7TYkmSlmIbcVsZi6rN9VvO7pOwy3tw4bPBj0IYX1OsDv1OTKPzKWPtTCY3Fa485vSRJP8y77OxlgzTSjhmskrWQNXd3rftjbuvWzg8uCVhh0edbo3TU5+z6dcMszkU1m7nPeyYp2pOcamKyXkOAgamfrqvOzPVun1OEwpc/5b7mSPufnGREj35RTWqYAFDpZ3BeUaHOKRwoUSsMNuoNPeaR723YZVhduaAUKZdnycHffduRWsp7S723AMWyaLw== support_pub_key" >> /home/ansible/.ssh/authorized_keys
  - chown -R ansible:ansible /home/ansible/.ssh
  - chmod 700 /home/ansible/.ssh
  - chmod 600 /home/ansible/.ssh/authorized_keys
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
  - useradd ansiblebot
  - echo "ansiblebot ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
  - yum clean all
  - rm -rf /var/cache/yum
EOF
```

This files serves two purposes: the first one is quite evident (installing `qemu-guest-agent`), while the second purpose may not be as obvious. Due to the sequencing of CloudInit, it initiates after networking, resulting in the inability to SSH or even ping the VM using the assigned name. However, this package is executed only once, so following the reboot, you will have full accessibility to the VM.

Before start creating the image, open datacenter → storage → select local → add snippets to contents list:

![Datacenter -> Storage -> Local](proxmox-noble-server-cloudimg/6xdsxi3s.png)

![Added Snippets to Content](proxmox-noble-server-cloudimg/laa4mrso.png)

## Build cloudinit image

```bash
sh build-cloudinit-image-server.sh
sh build-cloudinit-image-desktop.sh
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
sh create-vm-cloned-server.sh
sh create-vm-cloned-desktop.sh
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
```

<!--
donutuse
password
-->