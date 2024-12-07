# Azure
This repo contains Azure Cloud related stuff.

## rhel8-golden-image
This folder contains manifests how to create `RHEL 8` golden image for Azure Cloud.

```bash
packer build rhel8.pkr.hcl
```
If above command is completed successfully, there must be qcow image `.packer/output` folder.

You must convert to raw image before you convert it to `vhd` format.

```bash
qemu-img convert -f qcow2 -O raw .packer/output/rhel8-kvm.qcow2 rhel8-kvm.raw
```

All Microsoft Azure VM images must be in a fixed `VHD` format. The image must be aligned on a 1 MB boundary before it is converted to VHD. Following command checks if image format aligned properly.

```bash
./align.sh rhel8-kvm.raw
```

```bash
qemu-img convert -f raw -o subformat=fixed,force_size -O vpc rhel8-kvm.raw rhel8.vhd
```
Once the image is converted to VHD format. Next step is to upload image to Storage account and create VM image from image in
Storage account.


