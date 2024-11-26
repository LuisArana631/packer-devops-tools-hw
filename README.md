# Herramientas Devops

---

## Introducción

En esta actividad, aprenderás a utilizar Packer mediante un ejemplo sencillo, pero con una stack (pila) tecnológica muy utilizada. Los objetivos que se pretenden conseguir son los siguientes:


  - Aplicar la herramienta a la adaptación de unas instrucciones a automatismos para crear imágenes reutilizables.

  - Crear una template (plantilla) de Packer que te permita generar una imagen con una aplicación con Node.js ya instalada y configurada con Nginx como servidor web. 

  - Realizar el despliegue en una nube pública (se recomienda Amazon AWS, pero es opcional).

  - Ejecutar un despliegue automático, sin intervención manual.

## Requisitos

Para realizar esta actividad necesitarás los siguientes recursos:

  - Una cuenta en GitHub.

  - Una cuenta en Amazon AWS.

  - Una cuenta en AZURE.

  - Una cuenta en Docker Hub.

  - Un entorno de desarrollo con Packer instalado.

  - Un entorno de desarrollo con Docker instalado.

  - Un entorno de desarrollo con Node.js instalado.

  - Un entorno de desarrollo con Nginx instalado.

  - Un entorno de desarrollo con Git instalado.

  - Un entorno de desarrollo con PM2 instalado.

## Desarrollo

### Crear un repositorio en GitHub

1. Crea un repositorio en GitHub con el nombre que desees.

2. Clona el repositorio en tu entorno de desarrollo.

3. Crea un archivo README.md con la descripción de la actividad.

4. Realiza un commit con el mensaje "Creación del repositorio".

5. Realiza un push al repositorio remoto.

### Crear un proyecto básico de Node.js

1. Crea un proyecto básico de Node.js en tu entorno de desarrollo.

2. Crea un archivo app.js con el siguiente contenido:

```javascript
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('¡Hola Mundo!');
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Servidor corriendo en puerto ${PORT}`);
});
```

### Configurar Nginx como Proxy Inverso

1. Navega a la carpeta sites-available de Nginx.

```bash
cd /etc/nginx/sites-available
```

2. Crea un archivo de configuración para tu aplicación.

```bash
sudo nano express_app
```

3. Agrega la siguiente configuración:

```nginx
server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

4. Crea un enlace simbólico en la carpeta sites-enabled.

```bash
sudo ln -s /etc/nginx/sites-available/express_app /etc/nginx/sites-enabled/express_app
```

5. Eliminar el archivo default de sites-enabled.

```bash
sudo rm /etc/nginx/sites-enabled/default
```

6. Reinicia el servicio de Nginx.

```bash
sudo systemctl restart nginx
```

7. Prueba que tu aplicación de Node.js está funcionando correctamente.

### Crear una template de Packer (EJEMPLO)

1. Copia el archivo nginx.conf en la carpeta de tu proyecto.

2. Crea un archivo .pkr.hcl con la siguiente configuración:

```hcl
packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "devops-tools-nginx-nodejs"
  instance_type = "t2.micro"
  region        = "us-west-2"
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
  name    = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
}
```

3. Configura tus credenciales para poder acceder a tu cuenta de AWS. Para obtener tus credenciales de AWS puedes ir a tu usuario > Security Credentials > Access keys.

```bash
export AWS_ACCESS_KEY_ID="<YOUR_AWS_ACCESS_KEY_ID>"
export AWS_SECRET_ACCESS_KEY="<YOUR_AWS_SECRET_ACCESS_KEY>"
``` 

4. Formatea el archivo .pkr.hcl.

```bash
packer fmt .
```

5. Valida el archivo .pkr.hcl.

```bash
packer validate .
```

6. Ejecuta el comando packer build.

```bash
packer build .
```

### Crear una template de Packer (Con el )
##

2. Elige la AMI de base para la región 

    https://cloud-images.ubuntu.com/locator/ec2/

3. Crea un archivo de configuración de Packer en formato

```json
{
  "builders": [{
    "type": "amazon-ebs",
    "access_key": "TU_ACCESS_KEY",
    "secret_key": "TU_SECRET_KEY",
    "region": "us-east-1",
    "source_ami": "ami-0b0ea68c435eb488d",
    "instance_type": "t2.micro",
    "ssh_username": "ubuntu",
    "ami_name": "packer-nodejs-nginx {{timestamp}}"
  }],
  "provisioners": [{
    "type": "shell",
    "inline": [
      "sudo apt-get update",
      "sudo apt-get install -y nodejs npm nginx"
    ]
  }]
}
```