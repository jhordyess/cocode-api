#!/bin/bash

# Crear la red para los contenedores, no necesario si la base de datos está en la nube!!
docker network create localnet

# Configurar y ejecutar el contenedor MySQL
docker run -d \
  --name dockerized_mysql \
  --restart=always \
  -p 3306:3306 \
  -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
  -e MYSQL_USER=john \
  -e MYSQL_PASSWORD=doe \
  -e MYSQL_DATABASE=dockerized \
  --network=localnet \
  -v mysql-data:/var/lib/mysql \
  mysql:8.2

# Esperar unos segundos para asegurar que MySQL esté funcionando antes de iniciar el backend
sleep 10

# Construir y ejecutar el contenedor del backend
docker build -t backend_image .

docker run -d \
  --name dockerized_backend \
  --restart=always \
  -p 8080:8080 \
  -e DB_URL=jdbc:mysql://dockerized_mysql:3306 \
  -e DB_DEV_USER=john \
  -e DB_DEV_KEY=doe \
  -e DB=dockerized \
  --network=localnet \
  backend_image
