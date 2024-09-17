packer {
  required_plugins {
    hyperv = {
      source  = "github.com/hashicorp/hyperv"
      version = "~> 1"
    }
  }
}

locals {
  vm_name            = "ubuntu-docker"
  username           = "user"
  password           = "user"
  password_encrypted = "$6$PcyZvDkRbIL5hoq$APXsKYsL6j4woXn6i8w6jwFjfF9t1J5RtUPt4rc.zBh3l78CDdgAWpoYiGVqAkiyBOCcQ1Vp4YczhoheCZS2l."
  output_dir         = "output"
}

source "hyperv-iso" "ubuntu-server" {
  vm_name            = local.vm_name
  generation         = 2
  enable_secure_boot = false
  iso_url            = "ubuntu-24.04.1-live-server-amd64.iso"
  iso_checksum       = "sha256:e240e4b801f7bb68c20d1356b60968ad0c33a41d00d828e74ceb3364a0317be9"
  output_directory   = "${local.output_dir}/hyperv"
  http_content       = {
    "/user-data" = templatefile("src/templates/http/user-data.pkrtpl.hcl", {
      username           = local.username
      password_encrypted = local.password_encrypted
      hostname           = local.vm_name
    })
    "/meta-data" = ""
  }
  switch_name  = "Default Switch"
  boot_command = [
    "<wait3s>c<wait3s>",
    "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{ .HTTPIP }}:{{ .HTTPPort }}/\"",
    "<enter><wait>",
    "initrd /casper/initrd",
    "<enter><wait>",
    "boot",
    "<enter>"
  ]
  boot_wait        = "10s"
  cpus             = 4
  memory           = 4096
  disk_size        = 200000
  headless         = true
  shutdown_command = "echo '${local.password}' | sudo -S -E shutdown -P now"
  communicator     = "ssh"
  ssh_username     = local.username
  ssh_password     = local.password
  ssh_host         = "${local.vm_name}.mshome.net"
  ssh_timeout      = "1h"
}

build {
  sources = ["hyperv-iso.ubuntu-server"]
  provisioner "shell" {
    execute_command  = "echo '${local.password}' | sudo -S env {{ .Vars }} {{ .Path }}"
    environment_vars = [
      "DOCKER_USERNAME=${local.username}"
    ]
    scripts = [
      "src/scripts/network.sh",
      "src/scripts/docker-engine.sh"
    ]
  }
  post-processor "compress" {
    compression_level = 9
    output            = "${local.output_dir}/${local.vm_name}.tar.gz"
  }
}
