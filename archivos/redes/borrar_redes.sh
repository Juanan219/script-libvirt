#!/bin/bash
# Definición de variables
echo ' '
read -p "Nombre de la red que quieres eliminar: " NOMBRE

# Comprobación de archivos
if [[ -f virsh/redes/red-$NOMBRE.xml ]]
then
	echo ' '
	echo "Eliminando el fichero red-$NOMBRE.xml"
# Eliminar fichero xml
	rm virsh/redes/red-$NOMBRE.xml
else
	echo "No existe el fichero de red red-$NOMBRE.xml"
fi