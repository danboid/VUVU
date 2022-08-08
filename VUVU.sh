#!/bin/bash

# VUVU - VirtualBox Ubuntu VM Upstander
# by Dan MacDonald

# VUVU automates the creation of VirtualBox Ubuntu Server VMs.
# The default partitioning scheme is configured how LTSP prefers its images, as a single ext4 partition.
# Check the user variables are defined correctly first then run it as a normal user under X or Wayland.


########## USER VARIABLES ##########

# Name to use for new virtual machine
VMNAME=testvm

# Size of VM hard disk in MB
HDDSIZE=25000

# URL prefix of Ubuntu server .iso and its SHA256SUMS
PREFIX=https://releases.ubuntu.com/22.04/

# Ubuntu Server iso filename (must be 20.04 or later)
ISO=ubuntu-22.04-live-server-amd64.iso

####### END OF USER VARIABLES #######


# Check required software is installed

if ! command -v VBoxManage &> /dev/null
then
    echo "You must install VirtualBox before you can run VUVU."
    exit
fi

if ! command -v cloud-localds &> /dev/null
then
    echo "You must install cloud-image-utils before you can run VUVU."
    exit
fi

if ! command -v wget &> /dev/null
then
    echo "You must install wget before you can run VUVU."
    exit
fi

# Ensure VUVU dir exists
if [ ! -d ${HOME}/VirtualBox\ VMs/VUVU ]; then
  mkdir -p ${HOME}/VirtualBox\ VMs/VUVU
fi

# Check if VM already exists
if [ -d ${HOME}/VirtualBox\ VMs/${VMNAME} ]; then
  echo A VM with the name ${VMNAME} already exists
  exit
fi

# Download iso if it hasn't been downloaded already
echo Downloading iso
if [ ! -f ${HOME}/VirtualBox\ VMs/VUVU/${ISO} ]; then
  wget -O ${HOME}/VirtualBox\ VMs/VUVU/${ISO} ${PREFIX}${ISO}
fi

# Download SHA256SUMS
wget -O ${HOME}/VirtualBox\ VMs/VUVU/SHA256SUMS ${PREFIX}SHA256SUMS

echo Checking SHA256SUMS
cd ${HOME}/VirtualBox\ VMs/VUVU/
sha256sum --check --ignore-missing SHA256SUMS
if [ $? != 0 ]; then
  echo Ubuntu Server iso failed sha256sum check
  exit
fi

# Create empty cloud-init meta-data file
touch ${HOME}/VirtualBox\ VMs/VUVU/meta-data

# Create default cloud-init user-data file if missing
if [ ! -f ${HOME}/VirtualBox\ VMs/VUVU/user-data ]; then
  cat > ${HOME}/VirtualBox\ VMs/VUVU/user-data << 'EOF'
#cloud-config
autoinstall:
  apt:
    disable_components: []
    geoip: true
    preserve_sources_list: false
    primary:
    - arches:
      - amd64
      - i386
      uri: http://gb.archive.ubuntu.com/ubuntu
    - arches:
      - default
      uri: http://ports.ubuntu.com/ubuntu-ports
  drivers:
    install: false
  identity:
    hostname: ltspbase
    password: "$6$exDY1mhS4KUYCE/2$zmn9ToZwTKLhCw.b4/b.ZRTIZM30JZ4QrOQ2aOXJ8yk96xpcCof0kxKwuX1kqLG/ygbJ1f8wxED22bTL4F46P0"
    realname: ubuntu
    username: ubuntu
  kernel:
    package: linux-generic
  keyboard:
    layout: gb
    toggle: null
    variant: ''
  locale: en_GB.UTF-8
  network:
    ethernets:
      enp0s3:
        dhcp4: true
    version: 2
  ssh:
    allow-pw: true
    authorized-keys: []
    install-server: false
  storage:
    config:
    - ptable: msdos
      path: /dev/sda
      wipe: superblock-recursive
      preserve: false
      name: ''
      grub_device: true
      type: disk
      id: disk-sda
    - device: disk-sda
      size: -1
      wipe: superblock
      flag: ''
      number: 1
      preserve: false
      grub_device: false
      type: partition
      id: partition-0
    - fstype: ext4
      volume: partition-0
      preserve: false
      type: format
      id: format-0
    - path: /
      device: format-0
      type: mount
      id: mount-0
  updates: security
  version: 1
EOF
fi

# Create cloud-init iso
cloud-localds seed.iso user-data meta-data

# Create new VM
VBoxManage createvm --name ${VMNAME} --ostype "Ubuntu_64" --register --basefolder ${HOME}/VirtualBox\ VMs/

# Configure CPU cores and memory
VBoxManage modifyvm ${VMNAME} --cpus 2 --memory 4096 --vram 128

# Create ltsp-image compatible VMDK format disk image
VBoxManage createhd --filename ${HOME}/VirtualBox\ VMs/${VMNAME}/${VMNAME}.vmdk --size ${HDDSIZE} --format VMDK

# Add a SATA controller
VBoxManage storagectl ${VMNAME} --name "SATA Controller" --add sata --controller IntelAhci

# Attach HDD image
VBoxManage storageattach ${VMNAME} --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium ${HOME}/VirtualBox\ VMs/${VMNAME}/${VMNAME}.vmdk

# Attach Ubuntu iso
VBoxManage storageattach ${VMNAME} --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium ${HOME}/VirtualBox\ VMs/VUVU/${ISO}

# Attach cloud-init iso
VBoxManage storageattach ${VMNAME} --storagectl "SATA Controller" --port 2 --device 0 --type dvddrive --medium ${HOME}/VirtualBox\ VMs/VUVU/seed.iso

# Launch VM
VBoxManage startvm ${VMNAME}
