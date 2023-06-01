# terraform
Repo para pruebas y chapuzas con terraform, proximamente kubernetes y cositas

Para el despliegue en azure debemos estar conectados con azure
az login en powershell


Importante asociar la red virtual con la nic y crear las reglas para el puerto 22
IP Publica dejarla en estatico, azure asigna una por defecto

Generar las claves de ssh y especificarlas en el fichero junto al usuario permitido
