#cloud-config
autoinstall:
  version: 1
  early-commands:
    - systemctl stop ssh
  timezone: Europe/Moscow
  drivers:
    install: true
  oem:
    install: false
  network:
    version: 2
    ethernets:
      eth0:
        dhcp4: true
  source:
    id: ubuntu-server-minimal
  apt:
    preserve_sources_list: false
    mirror-selection:
      primary:
        - country-mirror
        - uri: http://archive.ubuntu.com/ubuntu
          arches: [amd64, i386]
        - uri: http://ports.ubuntu.com/ubuntu-ports
          arches: [default]
  identity:
    hostname: ${hostname}
    password: ${password_encrypted}
    realname: ${username}
    username: ${username}
  ssh:
    install-server: true
    allow-pw: true
  packages:
    - openssh-server
    - open-vm-tools
    - cloud-init
  storage:
    layout:
      name: direct
