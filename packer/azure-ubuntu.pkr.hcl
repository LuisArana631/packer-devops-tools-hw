packer {
  required_plugins {
    azure = {
      version = ">= 1.9.0"
      source  = "github.com/hashicorp/azure"
    }
  }
}

source "azure-arm" "autogenerated_1" {  
  use_azure_cli_auth                = true
  azure_tags                        = {
                                        dept = "Engineering"
                                        task = "Image deployment"
                                      }
  image_offer                       = "0001-com-ubuntu-server-jammy"
  image_publisher                   = "canonical"
  image_sku                         = "22_04-lts"
  location                          = "East US"
  managed_image_name                = "myPackerImage"
  managed_image_resource_group_name = "devops-group-tools"
  os_type                           = "Linux"
  vm_size                           = "Standard_D2ads_v6"
}

build {
  sources = [
    "source.azure-arm.autogenerated_1"
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
