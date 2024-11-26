packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

source "amazon-ebs" "ubuntu" {
  region        = var.region
  ami_name      = "devops-tools-nginx-nodejs"
  instance_type = "t2.micro"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name = "packer-devops-template"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner = "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nodejs npm nginx",
      "sudo npm install -g n",
      "sudo n stable",
      "sudo mkdir -p /var/www/html",
    ]
  }
}
