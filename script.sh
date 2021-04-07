#!/bin/bash

# Comprueba si está creado el árbol de directorios necesario

if [[ ! -d ../virsh ]];
then
	cd ..
	export PATH=$(pwd)/virsh
	echo "Creando el árbol de directorios en $PATH"
	mkdir -p ../virsh/dominios ../virsh/plantillas ../virsh/pools ../virsh/redes ../virsh/volumenes 
else
	echo 'Está creado'
fi

# Abre el Menú principal
echo '+-------------------+'
echo '|    Menú virsh     |'
echo '+-------------------+'
echo '| 1.- Crear red     |'
echo '| 2.- Crear pool    |'
echo '| 3.- Crear volumen |'
echo '| 4.- Crear dominio |'
echo '| 5.- Práctica      |'
echo '+-------------------+'
echo ' '
echo 'Pulsa cualquier otra tecla para salir...'
echo ' '
read -p "Opción: " OPCION

if [[ $OPCION -eq 1 ]];
then
	. archivos/comprobar_plantilla_redes.sh
elif [[ $OPCION -eq 2 ]];
then
	echo ' '
	echo 'Crear pool'
elif [[ $OPCION -eq 3 ]];
then
	echo ' '
	echo 'Crear volumen'
elif [[ $OPCION -eq 4 ]];
then
	echo ' '
	echo 'Crear dominio'
elif [[ $OPCION -eq 5 ]];
then
	. archivos/practica/practica.sh
else
	echo 'Saliendo ...'
	exit
fi
