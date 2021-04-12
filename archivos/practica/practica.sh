#!/bin/bash

# Creamos el pool para la práctica
	# Definimos las variables necesarias para el pool
export ID=$(cat /proc/sys/kernel/random/uuid)
export RUTA=$(pwd)
if [[ ! -d virsh/pools/pool1 ]]
then
        mkdir virsh/pools/pool1
fi
if [[ ! -d virsh/pools/fichero_xml ]]
then
        mkdir virsh/pools/fichero_xml
fi
export NOMBRE='pool1'
export COMPROBACION=0
read -p 'Inserta la ruta del pool por defecto: ' RUTA_POOL
while [[ -z $RUTA_POOL ]]
do
	read -p 'Inserta la ruta del pool por defecto: ' RUTA_POOL
	COMPROBACION=$(($COMPROBACION + 1))
	if [[ $COMPROBACION -eq 3 ]]
	then
		echo 'Ha fallado 3 veces'
		echo ' '
		echo 'Saliendo...'
		exit 1
	fi
done
	# Comprobación de que el pool por defecto existe
COMPROBACION=0
while [[ ! -d $RUTA_POOL ]]
do
	echo "No extiste el directorio $RUTA_POOL"
	echo ' '
	COMPROBACION=$(($COMPROBACION + 1))
	if [[ $COMPROBACION -eq 3 ]]
	then
		echo 'Ha fallado 3 veces'
		echo ' '
		echo 'Saliendo...'
		exit 1
	fi
	read -p 'Inserta la ruta correcta del pool por defecto: ' RUTA_POOL
done
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
export NOMBRE='intra'
export ID=$(cat /proc/sys/kernel/random/uuid)
export MAC=$(openssl rand -hex 3 | sed 's/\(..\)\(..\)\(..\)/52:54:00:\1:\2:\3/')

	# Modificamos el fichero xml con las variables
cp virsh/plantillas/plantilla-red.xml virsh/redes/red-intra.xml
sed -i "s/{{ NOMBRE }}/$NOMBRE/g" virsh/redes/red-intra.xml
sed -i "s/{{ TARJETA_RED }}/$TARJETA_RED/g" virsh/redes/red-intra.xml
sed -i "s/{{ ID }}/$ID/g" virsh/redes/red-intra.xml
sed -i "s/{{ MAC }}/$MAC/g" virsh/redes/red-intra.xml

	# Creamos la red intra y la activamos
virsh -c qemu:///system net-define virsh/redes/red-intra.xml
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
export COMPROBACION=0
export IP1=$(virsh -c qemu:///system net-dhcp-leases intra | grep $MAC1 | grep -o '10.10.20.\{0,9\}\{1,3\}' | cut -d '/' -f 1)
while [[ -z $IP1 ]]
do
	export IP1=$(virsh -c qemu:///system net-dhcp-leases intra | grep $MAC1 | grep -o '10.10.20.\{0,9\}\{1,3\}' | cut -d '/' -f 1)
	COMPROBACION=$(($COMPROBACION + 1))
	if [[ $COMPROBACION -eq 30 ]]
	then
		echo 'Han transcurrido 30 segundos.'
		echo ' '
		echo 'Saliendo...'
		exit 1
	fi
	sleep 1
done
	virsh -c qemu:///system attach-disk maquina1 $RUTA_POOL/vol1 vdb
# Le damos formato al volumen y creamos el directorio en maquina1 para conectar el vol1
echo 'Conectando el volumen...'
sleep 1
ssh debian@$IP1 sudo mkfs.xfs /dev/vdb
ssh debian@$IP1 sudo mkdir /var/lib/postgresql
ssh debian@$IP1 sudo mount /dev/vdb /var/lib/postgresql
# Creamos el usuario postgres y le asignamos los permisos del directorio creado
ssh debian@$IP1 sudo cp -r /home/debian/.ssh /var/lib/postgresql
ssh debian@$IP1 sudo groupadd -g 2000 postgres
ssh debian@$IP1 sudo useradd -d /var/lib/postgresql -g postgres  -u 2000 -s /bin/bash postgres
ssh debian@$IP1 sudo chown -R postgres. /var/lib/postgresql
# Instalamos postgresql
ssh debian@$IP1 sudo apt-get update
ssh debian@$IP1 sudo apt-get install -y postgresql
# Creamos un usuario y base de datos de prueba
ssh postgres@$IP1 psql<<EOF
create database prueba;
create user prueba with password 'prueba';
grant all privileges on database prueba to prueba;
EOF

# Modificamos los ficheros para que la base de datos sea accesible desde el exterior y aplicamos los cambios
ssh debian@$IP1 << EOF
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/11/main/postgresql.conf
sudo chown debian. /etc/postgresql/11/main/pg_hba.conf
sudo echo ' ' >> /etc/postgresql/11/main/pg_hba.conf
sudo echo '# MODIFICADO CON SCRIPT' >> /etc/postgresql/11/main/pg_hba.conf
sudo echo 'host    all             all             0.0.0.0/0               md5' >> /etc/postgresql/11/main/pg_hba.conf
sudo chown postgres. /etc/postgresql/11/main/pg_hba.conf
sudo sudo systemctl restart postgresql
sudo sed -i 's/#   StrictHostKeyChecking ask/    StrictHostKeyChecking no/g' /etc/ssh/ssh_config
sudo systemctl restart ssh
sudo systemctl restart sshd
EOF

#Rellenamos la base de datos
cp virsh/plantillas/plantilla-pgpass ~/.pgpass
sed -i "s/{{ IP }}/$IP1/g" ~/.pgpass
chmod 0600 ~/.pgpass
echo ' '
echo 'SE HA CREADO LA BASE DE DATOS "prueba" Y EL USUARIO "prueba" CON LA CONTRASEÑA "prueba"'
echo ' '
psql -U prueba -d prueba -h $IP1 -c "create table Prueba
(Columna1 varchar(10),
 Columna2 varchar(10),
 Columna3 varchar(10),
 constraint pk_prueba primary key (Columna1)
);
insert into Prueba
values('Texto 1', 'Texto 2', 'Texto 3');
insert into Prueba
values('Texto 4', 'Texto 5', 'Texto 6');
insert into Prueba
values('Texto 7', 'Texto 8', 'Texto 9');"

#Creamos las reglas de iptables
ssh debian@$IP1 sudo iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
ssh debian@$IP1 sudo iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
ssh debian@$IP1 sudo iptables -A OUTPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
ssh debian@$IP1 sudo iptables -A INPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
ssh debian@$IP1 sudo iptables -A INPUT -p tcp --dport 5432 -m state --state NEW,ESTABLISHED -j ACCEPT
ssh debian@$IP1 sudo iptables -A OUTPUT -p tcp --sport 5432 -m state --state ESTABLISHED -j ACCEPT
ssh debian@$IP1 sudo iptables -P INPUT DROP
ssh debian@$IP1 sudo iptables -P OUTPUT DROP
ssh debian@$IP1 sudo iptables -P FORWARD DROP

# Pausamos la ejecución del script hasta que el usuario pulse 'C'
echo ' '
echo 'Se ha pausado la ejecución del script para poder comprobar los pasos realizados'
echo ' '
echo "La IP de la máquina 'maquina1' es: $IP1"
echo ' '
read -p "Pulsa C para continuar: " CONTINUAR
while [ $CONTINUAR != 'C' ]
do
	echo 'Error: El caracter tiene que ser "C"'
	echo ' '
	read -p "Pulsa C para continuar: " CONTINUAR
done
rm ~/.pgpass

# Creamos la imagen de maquina2
export RUTA=$(pwd)
cd virsh/pools/pool1
qemu-img create -f qcow2 -b buster-base.qcow2 maquina2.qcow2 4G
cd $RUTA

# Creamos la maquina2
	# Definimos las variables
export NOMBRE='maquina2'
export ID=$(cat /proc/sys/kernel/random/uuid)
export RAM_TOTAL='1'
export RAM='1'
export VCPU='1'
export MAC2=$(openssl rand -hex 3 | sed 's/\(..\)\(..\)\(..\)/52:54:00:\1:\2:\3/')
		# Definición de la variable ruta
export RUTA=$(pwd)
echo $RUTA > provisional.txt
sed -i 's/\//__/g' provisional.txt
export RUTA=$(cat provisional.txt)
rm provisional.txt

	# Modificamos el fichero xml con las variables
cp virsh/plantillas/plantilla-dominio.xml virsh/dominios/maquina2.xml
sed -i "s/{{ NOMBRE }}/$NOMBRE/g" virsh/dominios/maquina2.xml
sed -i "s/{{ ID }}/$ID/g" virsh/dominios/maquina2.xml
sed -i "s/{{ RAM_TOTAL }}/$RAM_TOTAL/g" virsh/dominios/maquina2.xml
sed -i "s/{{ RAM }}/$RAM/g" virsh/dominios/maquina2.xml
sed -i "s/{{ VCPU }}/$VCPU/g" virsh/dominios/maquina2.xml
sed -i "s/{{ RUTA }}/$RUTA/g" virsh/dominios/maquina2.xml
sed -i "s/__/\//g" virsh/dominios/maquina2.xml
sed -i "s/{{ MAC }}/$MAC2/g" virsh/dominios/maquina2.xml
sed -i "s/{{ TARJETA_RED }}/$TARJETA_RED/g" virsh/dominios/maquina2.xml

	# Creamos el dominio
virsh -c qemu:///system define virsh/dominios/maquina2.xml
virsh -c qemu:///system start maquina2

# Desmontamos y desconectamos el disco de maquina1 y lo conectamos en maquina2
ssh debian@$IP1 sudo systemctl stop postgresql
ssh debian@$IP1 sudo umount /dev/vdb
virsh -c qemu:///system detach-disk maquina1 vdb
echo 'Concediendo IP...'
export COMPROBACION=0
export IP2=$(virsh -c qemu:///system net-dhcp-leases intra | grep $MAC2 | grep -o '10.10.20.\{0,9\}\{1,3\}' | cut -d '/' -f 1)
while [[ -z $IP2 ]]
do
	export IP2=$(virsh -c qemu:///system net-dhcp-leases intra | grep $MAC2 | grep -o '10.10.20.\{0,9\}\{1,3\}' | cut -d '/' -f 1)
	COMPROBACION=$(($COMPROBACION + 1))
	if [[ $COMPROBACION -eq 30 ]]
	then
		echo 'Han transcurrido 30 segundos.'
		echo ' '
		echo 'Saliendo...'
		exit 1
	fi
	sleep 1
done
virsh -c qemu:///system attach-disk maquina2 $RUTA_POOL/vol1 vdb

# Creamos el grupo, el directorio y usuario en maquina2
ssh debian@$IP2<<EOF
sudo mkdir /var/lib/postgresql
sudo cp -r /home/debian/.ssh /var/lib/postgresql
sudo groupadd -g 2000 postgres
sudo useradd -u 2000 -g postgres -s /bin/bash -d /var/lib/postgresql postgres
sudo chown -R postgres. /var/lib/postgresql
sudo apt-get update
sudo apt-get install -y postgresql
sudo mount /dev/vdb /var/lib/postgresql
EOF

# Pasamos los archivos de configuración de maquina1 a maquina2
ssh debian@$IP1<<EOF
sudo tar zcvf postgresql.tar /etc/postgresql
scp -o "StrictHostKeyChecking no" /home/debian/postgresql.tar debian@$IP2:/home/debian
EOF

# Descomprimimos el fichero tar en maquina2 y movemos los ficheros a su ubicacion
ssh debian@$IP2<<EOF
tar xvf postgresql.tar
sudo systemctl stop postgresql
sudo rm -r /etc/postgresql
sudo mv etc/postgresql /etc
sudo chown -R postgres. /etc/postgresql
sudo systemctl start postgresql
EOF
export COMPROBACION=0
export ACTIVO=$(ssh debian@$IP2 sudo systemctl status postgresql | grep -o "active (exited)")
while [[ -z $ACTIVO ]]
do
	ssh debian@$IP2 sudo systemctl start postgresql
	export ACTIVO=$(ssh debian@$IP2 sudo systemctl status postgresql | grep -o "active (exited)")
	COMPROBACION=$(($COMPROBACION + 1))
	if [[ $COMPROBACION -eq 30 ]]
	then
		echo 'Han pasado 30 segundos y el proceso de postgresql no se ha iniciado'
		echo ' '
		echo 'Saliendo...'
		exit 1
	fi
	sleep 1
done
echo "La IP de maquina2 es: $IP2"
exit 0