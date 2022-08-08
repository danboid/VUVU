# VUVU

VUVU automates the creation of VirtualBox Ubuntu Server VMs.

VUVU downloads the ISO, checks its sha256 checksum, creates a new VBox VM and then installs Ubuntu Server in it using a partition scheme suitable for use as a LTSP disk image source.

## REQUIREMENTS

VUVU requires that both VirtualBox and cloud-image-utils are installed before it can be used.

Under Ubuntu and Debian, these can be installed by running:

```
sudo apt install virtualbox cloud-image-utils
```

It also requires `wget` and `sha256sum` but both of these are installed by default under Ubuntu.

## USAGE

Open VUVU.sh and check the user variables are set correctly. You will probably want to change at least the name of the VM by configuring VMNAME. Run the script as a normal user under X or Wayland.

The Ubuntu installation isn't 100% automated because you still have to type `yes` when the Ubuntu installer asks `Continue with autoinstall?`. You can edit the kernel arguments from the GRUB boot menu and manually add `autoinstall` to avoid the continue prompt. For a 100% automated install you would have to remaster the Ubuntu iso to include the `autoinstall` kernel boot argument by default.

The default username and password is **ubuntu**.
