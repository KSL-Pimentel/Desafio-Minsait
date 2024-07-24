#!/bin/bash

# Atualizar a lista de pacotes e instalar pacotes necessários
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Adicionar a chave GPG oficial do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Adicionar o repositório APT do Docker
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Instalar Docker
sudo apt-get update
sudo apt-get install -y docker-ce

# Iniciar e habilitar o serviço Docker
sudo systemctl start docker
sudo systemctl enable docker

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Criar arquivo Docker Compose
cat << EOF > /home/minsait/docker-compose.yml
version: '3'

services:
  db:
    image: mysql:5.7
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: GAud4mZby8F3SD6P
    volumes:
      - db_data:/var/lib/mysql

  wordpress:
    image: wordpress:latest
    restart: always
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_PASSWORD: GAud4mZby8F3SD6P
    ports:
      - "80:80"
    volumes:
      - wordpress_data:/var/www/html

volumes:
  db_data:
  wordpress_data:
EOF

# Criar Dockerfile para o contêiner WordPress (se necessário)
cat << EOF > /home/minsait/Dockerfile
# Usar a imagem oficial do WordPress do Docker Hub
FROM wordpress:latest
EOF

# Executar Docker Compose para iniciar WordPress e MySQL
cd /home/minsait
sudo docker-compose up -d