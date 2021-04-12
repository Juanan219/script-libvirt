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
export MAC=$(openssl rand -hex 3 | sed 's/\(..\)\(..\)\(..\)/52:54:00\1:\2:\3/')

# Copia y modificación de la plantilla
cp virsh/plantillas/plantilla-red.xml virsh/redes/red-$NOMBRE.xml
sed -i "s/{{ NOMBRE }}/$NOMBRE/g" virsh/redes/red-$NOMBRE.xml
sed -i "s/{{ TARJETA_RED }}/$TARJETA_RED/g" virsh/redes/red-$NOMBRE.xml
sed -i "s/{{ DIR_IP_1 }}/$DIR_IP_1/g" virsh/redes/red-$NOMBRE.xml
sed -i "s/{{ MASCARA }}/$MASCARA/g" virsh/redes/red-$NOMBRE.xml
sed -i "s/{{ IP_START }}/$IP_START/g" virsh/redes/red-$NOMBRE.xml
sed -i "s/{{ IP_END }}/$IP_END/g" virsh/redes/red-$NOMBRE.xml
sed -i "s/{{ ID }}/$ID/g" virsh/redes/red-$NOMBRE.xml
sed -i "s/{{ MAC }}/$MAC/g" virsh/redes/red-$NOMBRE.xml

# Crea la red
virsh -c qemu:///system net-define virsh/redes/red-$NOMBRE.xml
virsh -c qemu:///system net-start $NOMBRE
virsh -c qemu:///system net-list