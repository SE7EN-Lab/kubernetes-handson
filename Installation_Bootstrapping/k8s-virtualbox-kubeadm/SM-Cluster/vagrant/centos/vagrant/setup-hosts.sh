#!/bin/bash
set -e
IFNAME=$1
ADDRESS="$(ip -4 addr show $IFNAME | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
sed -e "s/^.*${HOSTNAME}.*/${ADDRESS} ${HOSTNAME} ${HOSTNAME}.local/" -i /etc/hosts

# remove ubuntu-bionic entry
# sed -e '/^.*ubuntu-bionic.*/d' -i /etc/hosts

# disable swap
swapoff -v /swapfile
sed -i '/swapfile/d' /etc/fstab
rm /swapfile

# Update /etc/hosts about other hosts
cat >> /etc/hosts <<EOF
192.168.7.11  master-1
192.168.7.21  worker-1
192.168.7.22  worker-2
EOF
