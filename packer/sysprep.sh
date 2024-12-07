#!/bin/bash

cat <<EOF > /etc/udev/rules.d/68-azure-sriov-nm-unmanaged.rules
SUBSYSTEM=="net", DRIVERS=="hv_pci", ACTION=="add", ENV{NM_UNMANAGED}="1"
EOF

cat <<EOF > /etc/cloud/cloud.cfg.d/91-azure_datasource.cfg
datasource_list: [ NoCloud, Azure ]
datasource:
  Azure:
    apply_network_config: false
EOF

cat <<EOF > /etc/cloud/cloud.cfg.d/10-azure-kvp.cfg
Reporting:
    logging:
        type: log
    telemetry:
        type: hyperv
EOF

cat <<EOF > /etc/dracut.conf.d/hv.conf
add_drivers+=" hv_vmbus "
add_drivers+=" hv_netvsc "
add_drivers+=" hv_storvsc "
add_drivers+=" nvme "
EOF

cat <<EOF > /etc/modprobe.d/blocklist.conf
blacklist nouveau
blacklist lbm-nouveau
blacklist floppy
blacklist amdgpu
blacklist skx_edac
blacklist intel_cstate
EOF

dracut -f -v --regenerate-all

sed -i 's/Provisioning.Agent=auto/Provisioning.Agent=cloud-init/g' /etc/waagent.conf
sed -i 's/ResourceDisk.Format=y/ResourceDisk.Format=n/g' /etc/waagent.conf
sed -i 's/ResourceDisk.EnableSwap=y/ResourceDisk.EnableSwap=n/g' /etc/waagent.conf

: > /etc/machine-id
: > /var/lib/dbus/machine-id
: > /var/log/audit/audit.log
: > /var/log/wtmp
: > /var/log/lastlog
: > /var/log/grubby

rm -rf /etc/ssh/ssh_host_*
rm -rf /root/.ssh/*
rm -rf /root/.gnupg/*
rm -f /root/anaconda-ks.cfg
rm -f /root/original-ks.cfg
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -rf /var/cache/*
rm -f /var/log/anaconda/*
rm -f /var/log/dmesg.old


rm -rf /root/install.log
rm -rf /root/install.log.syslog
rm -rf /var/lib/yum/*
yum clean all

rm -f /etc/sysconfig/rhn/systemid

rm -f /var/lib/systemd/random-seed

subscription-manager unsubscribe --all || true

subscription-manager unregister || true

subscription-manager clean || true

: > /etc/resolv.conf

rm -f /etc/udev/rules.d/70-persistent-net.rules
rm -f /etc/udev/rules.d/75-persistent-net-generator.rules
rm -f /etc/udev/rules.d/80-net-name-slot-rules

cp /etc/default/grub /etc/default/grub.orig

sed -i -n -e '/^GRUB_TIMEOUT_STYLE=/!p' -e '$aGRUB_TIMEOUT_STYLE=countdown' /etc/default/grub
sed -i -n -e '/^GRUB_TERMINAL=/!p' -e '$aGRUB_TERMINAL="serial console"' /etc/default/grub
sed -i -n -e '/^GRUB_SERIAL_COMMAND=/!p' -e '$aGRUB_SERIAL_COMMAND="serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1"' /etc/default/grub
sed -i 's/rhgb quiet//g' /etc/default/grub
sed -i 's/crashkernel=auto//g' /etc/default/grub
awk '/GRUB_CMDLINE_LINUX/{sub("\"$", "rootdelay=300 console=ttyS0 earlyprintk=ttyS0 net.ifnames=0\"")}1' /etc/default/grub > /etc/default/grub_tmp
mv /etc/default/grub_tmp /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg

waagent -force -deprovision+user

cloud-init clean --logs --seed

rm -f /etc/sysconfig/network-scripts/ifcfg-*

: > /root/bash_history
unset HISTFILE
