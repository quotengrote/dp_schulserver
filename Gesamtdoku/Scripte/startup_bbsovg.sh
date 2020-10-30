#!/bin/bash
# Mit diesem Bash-Script werden 15 Schüler-Dummys, 2 Lehrer-Dummys und 2 Admin-Dummys erstellt.
#Außerdem werden hier für die initiale Konfiguration VMs in den passenden Pools erstellt.
#Passwörter sind gegebenenfalls noch anzupassen.

#Wichtig für qm
export PATH=$PATH:/usr/sbin


#Gruppen werden erstellt
pveum groupadd schueler
pveum groupadd lehrer
pveum groupadd admins
echo "Gruppen erstellt"

#Gruppen Rolle zuweisen
pveum aclmod / -group schueler -role PVEAuditor
pveum aclmod / -group lehrer -role PVEVMAdmin
pveum aclmod / -group admins -role Administrator
echo "Rollen hinzugefügt"

#Lehrer und Admins erstellen
pveum useradd lehrer00@pve -group lehrer -password <passwort>
pveum useradd lehrer01@pve -group lehrer -password <passwort>
pveum useradd admin00@pve -group admins -password <passwort>
pveum useradd admin01@pve -group admins -password <passwort>
echo "lehrer und admins 0 und 1 erstellt"


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

#Für die bessere Sortierung in der GUI, Trennung von Einstelligen Nutzern wie schueler01 und zweistellige Nutzernummer schueler10
for ((i=1;i<=15;i++)) do

        if [ $i -lt 10 ]
                then
                  name_schueler='schueler0'
                  v_vmid='0'$i

                else
                  name_schueler='schueler'
                  v_vmid=$i
        fi
        # Dieser echo befehl ist wichtig um einen pool in der shell zu Erstellen einen eigenen Shellbefehl gibt es nicht
        echo pool:"p_"$name_schueler$i :::$storage: >> /etc/pve/user.cfg
        echo "Pool für "$name_schueler$i" hinzugefügt"

        #Schüler werden erstellt und auf pool berechtigt
        pveum useradd $name_schueler$i@pve -group schueler -password <passwort>
        pveum aclmod /pool/"p_"$name_schueler$i -user $name_schueler$i@pve -role PVEVMUser
        echo $name_schueler$i" wurde hinzugefügt(auch in Pool mit PVEVMUser Rechte)"

        #Switche werden erstellt(gegebenenfalls die Einrückung in nano anpassen)
        echo 'auto vmbr'$i >> /etc/network/interfaces
        echo 'iface vmbr'$i' inet manual' >> /etc/network/interfaces
        echo '  bridge-ports none' >> /etc/network/interfaces
        echo '  bridge-stp off' >> /etc/network/interfaces
        echo '  bridge-fd 0' >> /etc/network/interfaces
        echo ' ' >> /etc/network/interfaces

        ifup vmbr$i


        #VMs werden erstellt

        qm create 1$v_vmid --agent 1 --cdrom local:iso/$linux --cores 2 --scsi0 $storage:15 --kvm 1 --memory 2048 --net0 virtio,bridge=vmbr$i --name linuxVMschueler$v_vmid --ostype l26 --scsihw virtio-scsi-pci --pool "p_"$name_schueler$i
        echo "LinuxVM erstellt"
        qm create 2$v_vmid --agent 1 --cdrom local:iso/$win --cores 2 --scsi0 $storage:25,cache=writeback --ide3 local:iso/$virtio,media=cdrom --bootdisk  scsi0 --kvm 1 --memory 4096 --net0 virtio,bridge=vmbr$i --name win10VMschueler$v_vmid --ostype win10 --scsihw virtio-scsi-pci --pool "p_"$name_schueler$i
        echo "Win10VM erstellt"
        qm create 3$v_vmid --agent 1 --cdrom local:iso/$winserver --cores 2 --scsi0 $storage:25,cache=writeback --ide3 local:iso/$virtio,media=cdrom --bootdisk  scsi0 --kvm 1 --memory 4096 --net0 virtio,bridge=vmbr$i --name winserver2019VMschueler$v_vmid --ostype win10 --scsihw virtio-scsi-pci --pool "p_"$name_schueler$i
        echo "WinServerVM erstellt"
done
