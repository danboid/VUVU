# VUVU

VUVU automates the creation of VirtualBox Ubuntu Server VMs.

VUVU downloads the ISO, checks its sha256 checksum, creates a new VBox VM and then installs Ubuntu Server in it using a partition scheme suitable for use as a LTSP disk image source.

This repo also includes a simple Ansible playbook which could be used as the basis of creating a (LTSP) desktop image. It is likely most useful for its "Remove unwanted packages" task which lists most of the packages Ubuntu Server installs by default that you probabaly don't want installed on a desktop system.

## REQUIREMENTS

VUVU requires that both VirtualBox and cloud-image-utils are installed before it can be used.

Under Ubuntu and Debian, these can be installed by running:

```
sudo apt install virtualbox cloud-image-utils
```

It also requires `wget` and `sha256sum` but both of these are installed by default under Ubuntu.

## USAGE

Open VUVU.sh and check the user variables are set correctly, most importantly **ISO** and **PREFIX**. If ISO isn't set to the latest release of Ubuntu Server then the sha256 check will fail. Open the **PREFIX** URL in a browser to check what the latest ISO file name is. You may also want to change the name of the VM by setting **VMNAME**. After configuring the user variables, run the script in a terminal as a normal user under X or Wayland.

The Ubuntu installation isn't 100% automated because you still have to type `yes` when the Ubuntu installer asks `Continue with autoinstall?`. You can edit the kernel arguments from the GRUB boot menu and manually add `autoinstall` to avoid the continue prompt. For a 100% automated install you would have to remaster the Ubuntu iso to include the `autoinstall` kernel boot argument by default.

The default username and password is **ubuntu**.
