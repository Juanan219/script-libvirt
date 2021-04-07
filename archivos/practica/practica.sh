#!/bin/bash

# Creamos el pool para la práctica
	# Definimos las variables necesarias para el pool
export ID=$(cat /proc/sys/kernel/random/uuid)
export RUTA=$(pwd)
export NOMBRE='pool1'

	# Modificamos el fichero xml con las variables
cp virsh/plantillas/plantilla-pool.xml virsh/pools/fichero_xml/pool1.xml
sed -i "s/{{ ID }}/$ID/g" virsh/pools/fichero_xml/pool1.xml
sed -i "s/{{ NOMBRE }}/$NOMBRE/g" virsh/pools/fichero_xml/pool1.xml
		# Definición de la variable ruta
echo $RUTA > provisional.txt
sed -i 's/\//__/g' provisional.txt
export RUTA=$(cat provisional.txt)
rm provisional.txt
sed -i "s/{{ RUTA }}/$RUTA/g" virsh/pools/fichero_xml/pool1.xml
sed -i 's/__/\//g' virsh/pools/fichero_xml/pool1.xml


	# Creamos el pool y lo activamos
virsh -c qemu:///system pool-define virsh/pools/fichero_xml/pool1.xml
virsh -c qemu:///system pool-start pool1

# Descargar la imagen buster-base.qcow2 y la clave privada para usar dicha imagen

if [[ ! -f virsh/pools/pool1/buster-base.qcow2 ]];
then
	wget --no-check-certificate "https://www.dropbox.com/s/qdovr5l73qix5hk/buster-base.qcow2?dl=0" -O virsh/pools/pool1/buster-base.qcow2
fi
if [[ ! -d ~/.ssh ]];
then
	mkdir ~/.ssh
	wget --no-check-certificate "https://www.dropbox.com/s/ar5ziwgkiupp91o/kvm?dl=0" -O ~/.ssh/
elif [[ ! -f ~/.ssh/kvm ]];
then
	wget --no-check-certificate "https://www.dropbox.com/s/ar5ziwgkiupp91o/kvm?dl=0" -O ~/.ssh/
fi

# Creamos una imagen basada en buster-base.qcow2
export RUTA=$(pwd)
cd virsh/pools/pool1
qemu-img create -f qcow2 -b buster-base.qcow2 maquina1.qcow2 5G
cd $RUTA

# Creamos la red intra
	# Definimos las variables
read -p "Nombre de la nueva tarjeta de red: " TARJETA_RED
export ID=$(cat /proc/sys/kernel/random/uuid)
export MAC=$(openssl rand -hex 3 | sed 's/\(..\)\(..\)\(..\)/52:54:00:\1:\2:\3/')

	# Modificamos el fichero xml con las variables
cp virsh/plantillas/plantilla-red.xml virsh/redes/intra.xml
sed -i "s/{{ TARJETA_RED }}/$TARJETA_RED/g" virsh/redes/intra.xml
sed -i "s/{{ ID }}/$ID/g" virsh/redes/intra.xml
sed -i "s/{{ MAC }}/$MAC/g" virsh/redes/intra.xml

	# Creamos la red intra y la activamos
virsh -c qemu:///system net-define virsh/redes/intra.xml
virsh -c qemu:///system net-start intra

# Creamos la máquina maquina1
	# Definimos las variables
export NOMBRE='maquina1'
export ID=$(cat /proc/sys/kernel/random/uuid)
export RAM_TOTAL='2'
export RAM='1'
export VCPU='2'
export MAC1=$(openssl rand -hex 3 | sed 's/\(..\)\(..\)\(..\)/52:54:00:\1:\2:\3/')
		# Definición de la variable ruta
export RUTA=$(pwd)
echo $RUTA > provisional.txt
sed -i 's/\//__/g' provisional.txt
export RUTA=$(cat provisional.txt)
rm provisional.txt

	# Modificamos el fichero xml con las variables
cp virsh/plantillas/plantilla-dominio.xml virsh/dominios/maquina1.xml
sed -i "s/{{ NOMBRE }}/$NOMBRE/g" virsh/dominios/maquina1.xml
sed -i "s/{{ ID }}/$ID/g" virsh/dominios/maquina1.xml
sed -i "s/{{ RAM_TOTAL }}/$RAM_TOTAL/g" virsh/dominios/maquina1.xml
sed -i "s/{{ RAM }}/$RAM/g" virsh/dominios/maquina1.xml
sed -i "s/{{ VCPU }}/$VCPU/g" virsh/dominios/maquina1.xml
sed -i "s/{{ RUTA }}/$RUTA/g" virsh/dominios/maquina1.xml
sed -i "s/__/\//g" virsh/dominios/maquina1.xml
sed -i "s/{{ MAC }}/$MAC1/g" virsh/dominios/maquina1.xml
sed -i "s/{{ TARJETA_RED }}/$TARJETA_RED/g" virsh/dominios/maquina1.xml

	# Creamos el dominio
virsh -c qemu:///system define virsh/dominios/maquina1.xml
virsh -c qemu:///system start maquina1

# Creamos el vol1 en el pool por defecto
	# Definición de las variables
cp virsh/plantillas/plantilla-volumen.xml virsh/volumenes/vol1.xml
export NOMBRE='vol1'
export CAPACIDAD='1'
export TIPO='raw'
		# Definición de la variable RUTA_COMPLETA
virsh -c qemu:///system pool-dumpxml default | grep "<path>" | tr -d ' ' | sed 's/<path>/ /g' | sed 's/<\/path>/ /g' > provisional.txt
sed -i 's/\//__/g' provisional.txt
export RUTA_COMPLETA=$(cat provisional.txt)
rm provisional.txt

	# Modificamos el fichero xml con las variables definidas
sed -i "s/{{ RUTA_COMPLETA }}/$RUTA_COMPLETA/g" virsh/volumenes/vol1.xml
sed -i "s/{{ NOMBRE }}/$NOMBRE/g" virsh/volumenes/vol1.xml
sed -i "s/{{ CAPACIDAD }}/$CAPACIDAD/g" virsh/volumenes/vol1.xml
sed -i "s/{{ TIPO }}/$TIPO/g" virsh/volumenes/vol1.xml
	# Creamos el vol1 en el pool por defecto
virsh -c qemu:///system vol-create default virsh/volumenes/vol1.xml
# Conectamos el vol1 a maquina1
echo 'Concediendo IP...'
sleep 15
export IP1=$(virsh -c qemu:///system net-dhcp-leases intra | grep $MAC1 | grep -o '10.10.20.\{0,9\}\{1,3\}' | cut -d '/' -f 1)
read -p 'Inserta la ruta del pool por defecto: ' RUTA
virsh -c qemu:///system attach-disk maquina1 $RUTA/vol1 vdb
# Le damos formato al volumen y creamos el directorio en maquina1 para conectar el vol1
echo 'Conectando el volumen...'
sleep 1
ssh debian@$IP1 sudo mkfs.xfs /dev/vdb
ssh debian@$IP1 sudo mkdir /var/lib/postgresql
ssh debian@$IP1 sudo mount /dev/vdb /var/lib/postgresql
# Creamos el usuario postgres y le asignamos los permisos del directorio creado
ssh debian@$IP1 sudo cp -r /home/debian /home/postgres
ssh debian@$IP1 sudo groupadd postgres
ssh debian@$IP1 sudo useradd -d /home/postgres -g postgres -s /bin/bash postgres
ssh debian@$IP1 sudo chown -R postgres. /home/postgres
ssh debian@$IP1 sudo chown postgres. /var/lib/postgresql
# Instalamos postgresql
ssh debian@$IP1 sudo apt-get update
ssh debian@$IP1 sudo apt-get install -y postgresql
echo ' '