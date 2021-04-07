#!/bin/bash
virsh -c qemu:///system undefine maquina1
virsh -c qemu:///system destroy maquina1
virsh -c qemu:///system net-destroy intra
virsh -c qemu:///system net-undefine intra
virsh -c qemu:///system pool-destroy pool1
virsh -c qemu:///system pool-undefine pool1
virsh -c qemu:///system vol-delete vol1 default
rm virsh/dominios/maquina1.xml
rm virsh/pools/fichero_xml/pool1.xml
sudo rm virsh/pools/pool1/maquina1.qcow2
rm virsh/redes/intra.xml
rm virsh/volumenes/vol1.xml
sudo rm /libvirt/default_pool/vol1
