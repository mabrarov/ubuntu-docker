# Hyper-V VM with Docker Engine

Packer project building Hyper-V VM with:

1. Ubuntu Server 24.04
2. [Docker Engine](https://docs.docker.com/engine/)

Based on:

1. https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html
2. https://github.com/vmware-samples/packer-examples-for-vsphere/tree/develop/builds/linux/ubuntu/24-04-lts

## Build requirements

1. [Hyper-V](https://learn.microsoft.com/en-us/virtualization/hyper-v-on-windows/quick-start/enable-hyper-v)
2. 4 CPUs and 8GB memory
3. [Packer](https://developer.hashicorp.com/packer) 1.11.0+
4. Download ubuntu-24.04.1-live-server-amd64.iso from https://ubuntu.com/download/server
    and place it at the same directory where this README is located

## Building

Requires local administrator permissions (Hyper-V requirement).

```shell
packer init ubuntu-docker.pkr.hcl && packer build ubuntu-docker.pkr.hcl
```

The built VM is exported (removed from Hyper-V VM manager) and saved at output/ubuntu-docker.tar.gz.

## Usage

Import VM from unpacked output/ubuntu-docker.tar.gz.

SSH access:

1. Address: ubuntu-docker.mshome.net
2. Username: user
3. Password: user

Remote access to Docker daemon:

```shell
docker -H 'tcp://ubuntu-docker.mshome.net:2375' version
```
