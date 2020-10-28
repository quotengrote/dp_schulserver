
#### VM erstellen
`qm create 101 --agent 1 --cdrom local:iso/proxmox-ve_6.0-1.iso --cores 1 --scsi0 local-lvm:1 --kvm 0 --memory 2048 --net0 virtio,bridge=vmbr0 --name testvmcmd --ostype l26 --scsihw virtio-scsi-pci`

[qm Befehl](https://pve.proxmox.com/pve-docs/qm.1.html)
[KVM Virtual Machines PVE](https://pve.proxmox.com/wiki/Qemu/KVM_Virtual_Machines)
[Admin Guide](https://pve.proxmox.com/pve-docs/pve-admin-guide.html)
qm create 600 --net0 virtio,bridge=vmbr0 --name vm600 --serial0 socket \
  --bootdisk scsi0 --scsihw virtio-scsi-pci --ostype l26

qm create 9000 --memory 2048 --net0 virtio,bridge=vmbr0

qm create 300 -ide0 local-lvm:4 -net0 e1000 -cdrom local:iso/proxmox-mailgateway_2.1.iso

#### User erstellen
##### Quellen
https://pve.proxmox.com/wiki/User_Management#_command_line_tool

##### Nutzer erstellen
  - `pveum useradd <user_name>@pam`

##### Gruppe erstellen
  - `pveum groupadd <Gruppenname> -comment "<Kommentare>"`

##### Rolle erstellen
  - `pveum roleadd <Rollenname> -privs "<Rechte>"`

##### Gruppenrechte setzen
  - `pveum aclmod / -group <Gruppenname> -role <Rollenname>`

##### Nutzer zu Gruppe hinzufügen
  - `pveum usermod <user_name>@pam -group <Gruppenname>`
Nutzer erstellen
