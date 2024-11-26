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

  provisioner "shell" {
    inline = [
      "curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -",
      "sudo apt-get update",
      "sudo apt-get install -y nodejs nginx",
      "sudo npm install -g n",
      "sudo n stable",
      "sudo mkdir -p /var/www/node_app",
      "sudo chown -R ubuntu:ubuntu /var/www",
      "git clone https://github.com/LuisArana631/packer-devops-tools-hw.git /var/www/node_app",
      "cd /var/www/node_app/nodejs-project/src && sudo npm i",
      "sudo chown -R ubuntu:ubuntu /var/www/node_app",
      "echo '[Unit]\nDescription=Node.js App\n[Service]\nExecStart=/usr/bin/node /var/www/node_app/nodejs-project/src/app.js\nRestart=always\nUser=ubuntu\nEnvironment=PORT=3000\n[Install]\nWantedBy=multi-user.target' | sudo tee /etc/systemd/system/nodeapp.service",
      "sudo systemctl enable nodeapp",
      "sudo systemctl start nodeapp",
      "sudo cp /var/www/node_app/nodejs-project/nginx.conf /etc/nginx/sites-available/node_app",
      "sudo ln -s /etc/nginx/sites-available/node_app /etc/nginx/sites-enabled/",
      "sudo rm /etc/nginx/sites-enabled/default",
      "sudo nginx -t",
      "sudo systemctl restart nginx"
    ]
  }
}
