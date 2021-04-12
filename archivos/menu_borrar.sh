#!/bin/bash
# Abre el menú de eliminar
echo ' '
echo '¿Qué quieres eliminar?'
echo ' '
echo '+-----------------------+'
echo '| 1.- Eliminar Redes    |'
echo '| 2.- Eliminar Pool     |'
echo '| 3.- Eliminar Volumen  |'
echo '| 4.- Eliminar Dominio  |'
echo '| 5.- Eliminar Práctica |'
echo '+-----------------------+'
echo ' '
read -p "Opción: " OPCION

# Comprobación de opciones
if [[ $OPCION -eq 1 ]]
then
	echo ' '
	. archivos/redes/borrar_redes.sh
elif [[ $OPCION -eq 2 ]]
then
	echo ' '
	echo 'ELIMINAR POOL'
elif [[ $OPCION -eq 3 ]]
then
	echo ' '
	echo 'ELIMINAR VOLUMEN'
elif [[ $OPCION -eq 4 ]]
then
	echo ' '
	echo 'ELIMINAR DOMINIO'
elif [[ $OPCION -eq 5 ]]
then
	echo ' '
	echo 'ELIMINAR DATOS DE LA PRÁCTICA'
fi