packer {
  required_plugins {
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable ssh_passwd {
  type      = string
  sensitive = true
  default   = "CHANGEME"
}

source "qemu" "linux-rhel" {
  iso_url          = "/home/user/Downloads/rhel-8.10-x86_64-dvd.iso"
  iso_checksum     = "sha256:9b3c8e31bc2cdd2de9cf96abb3726347f5840ff3b176270647b3e66639af291b"
  output_directory = ".packer/output"
  shutdown_command = "echo '${var.ssh_passwd}' | sudo -S shutdown -P now"
  format           = "qcow2"
  accelerator      = "kvm"
  http_directory   = "http"
  ssh_username     = "user"
  ssh_password     = var.ssh_passwd
  ssh_timeout      = "20m"
  vm_name          = "rhel8-kvm.qcow2"
  net_device       = "virtio-net"
  disk_interface   = "virtio"
  boot_wait        = "3s"
  cpus             = "4"
  memory           = "4096"
  disk_size        = "7G"
  qemuargs = [
    [
      "-cpu",
      "host"
    ]
  ]
  boot_command = [
    "<tab><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kickstart.cfg",
    "<enter><wait>"
  ]
}

build {
  sources = ["source.qemu.linux-rhel"]
  provisioner "shell" {
    script          = "./sysprep.sh"
    execute_command = "echo 'user' | {{.Vars}} sudo -S -E sh -eux '{{.Path}}'"
  }
}

