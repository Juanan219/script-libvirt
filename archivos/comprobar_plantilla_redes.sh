#!/bin/bash

# Comprobación si existe una plantilla xml de red
if [[ ! -f ../virsh/plantillas/plantilla-red.xml ]];
then
	cd ..
	export PATH=$(pwd)
	echo 'No existe ninguna plantilla llamada plantilla-red.xml'
	echo "Tienes que crear una plantilla llamada plantilla-red.xml en el directorio $PATH/virsh/plantillas/"
	echo ' '
	echo 'Saliendo ...'
	exit
else
	. archivos/crear_redes.sh
fi