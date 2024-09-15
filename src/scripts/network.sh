#!/bin/bash

set -e

echo 'network: {config: disabled}' | tee /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg

tee /etc/netplan/99-config.yaml << EOF
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
    eth1:
      optional: true
      addresses:
        - 192.168.56.60/24
      routes:
        - to: 192.168.56.0/24
          via: 192.168.56.1
EOF

chmod u=rw,g=,o= /etc/netplan/99-config.yaml
rm /etc/netplan/50-cloud-init.yaml
