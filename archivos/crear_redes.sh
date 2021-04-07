#!/bin/bash

# Script de creación de redes

# Definición de variables

read -p "Nombre de la nueva red: " NOMBRE
read -p "Nombre de la tarjeta de red: " TARJETA_RED
read -p "Dirección IP tarjeta de red: " DIR_IP_1
read -p "Máscara de red: " MASCARA
read -p "Dirección IP de inicio del rango DHCP: " IP_START
read -p "Dirección IP final del rango DHCP: " IP_END
export ID=$(cat /proc/sys/kernel/random/uuid)
export DIR_MAC=$(openssl rand -hex 3 | sed 's/\(..\)\(..\)\(..\)/52:54:00\1:\2:\3/')

# Comprobaciones
export COMP=0
while comp