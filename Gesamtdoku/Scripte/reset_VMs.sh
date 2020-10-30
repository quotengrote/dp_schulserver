#!/bin/bash
#Dieses Script hat die Aufgabe alle alten VMs zu löschen zsm mit ihren Logical Volumes

#Das ganze ist der einfachheithalber in zwei For-Schleifen geschrieben,
#um bei Tests Codeblöcke besser Kopieren zu können.

#Wichtig für qm
export PATH=$PATH:/usr/sbin
#Variablen
###########################################################################
#                   !!!!!local_lvm umbenennen!!!!!                        #
###########################################################################
storage="local-lvm"
#ISO Variablen
linux="ubuntu-20.04.1-desktop-amd64.iso"
win="Win10_2004_German_x64.iso"
winserver="winserver2019.iso"
virtio="virtio-win-0.1.185.iso"

#Löschen der alten VMs
for ((i=1;i<=15;i++)) do

        if [ $i -lt 10 ]
                then
                  v_vmid='0'$i

                else
                  v_vmid=$i
        fi

        #VMs werden gelöscht
        qm stop 1$v_vmid --skiplock 1
        qm destroy 1$v_vmid --skiplock 1
        qm stop 2$v_vmid --skiplock 1
        qm destroy 2$v_vmid --skiplock 1
        qm stop 3$v_vmid --skiplock 1
        qm destroy 3$v_vmid --skiplock 1
done

#Wiederherstellung der VMs
for ((i=1;i<=15;i++)) do

        if [ $i -lt 10 ]
                then
                  name_schueler='schueler0'
                  v_vmid='0'$i

                else
                  name_schueler='schueler'
                  v_vmid=$i
        fi

        #VMs werden erstellt

        qm create 1$v_vmid --agent 1 --cdrom local:iso/$linux --cores 2 --scsi0 $storage:15 --kvm 1 --memory 2048 --net0 virtio,bridge=vmbr$i --name linuxVMschueler$v_vmid --ostype l26 --scsihw virtio-scsi-pci --pool "p_"$name_schueler$i
        echo "LinuxVM erstellt"
        qm create 2$v_vmid --agent 1 --cdrom local:iso/$win --cores 2 --scsi0 $storage:25,cache=writeback --ide3 local:iso/$virtio,media=cdrom --bootdisk  scsi0 --kvm 1 --memory 4096 --net0 virtio,bridge=vmbr$i --name win10VMschueler$v_vmid --ostype win10 --scsihw virtio-scsi-pci --pool "p_"$name_schueler$i
        echo "Win10VM erstellt"
        qm create 3$v_vmid --agent 1 --cdrom local:iso/$winserver --cores 2 --scsi0 $storage:25,cache=writeback --ide3 local:iso/$virtio,media=cdrom --bootdisk  scsi0 --kvm 1 --memory 4096 --net0 virtio,bridge=vmbr$i --name winserver2019VMschueler$v_vmid --ostype win10 --scsihw virtio-scsi-pci --pool "p_"$name_schueler$i
        echo "WinServerVM erstellt"
done
