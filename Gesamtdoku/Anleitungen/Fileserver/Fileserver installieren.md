# Fileserver mit Samba installieren
* für bestehende Kennwörter siehe Keepass.
## Installation
1. `sudo apt install samba cifs-utils samba-common samba-common-bin samba-vfs-modules -y`
## Nutzer + Gruppen erstellen
1. `sudo addgroup lehrer`
8. `sudo addgroup schueler`
9. `sudo addgroup admins`
10. `sudo useradd --no-create-home -g schueler schueler`
11. `sudo smbpasswd -a -n schueler`
10. `sudo useradd --no-create-home -g lehrer lehrer`
11. `sudo smbpasswd -a -n lehrer`
10. `sudo useradd --no-create-home -g admins admin`
11. `sudo smbpasswd -a -n admin`
12. mit smbpasswd für jeden Nutzer ein Kennwort setzen

## Dateisystem + Ordner für die freigegeben werden sollen erstellen
1. Dateisystem auf mpath-device erstellen
1.1 `mkfs.ext4 /dev/mapper/<n>`
2. mounten mit in /etc/fstab
2.1 ```/pfad/zu/<fs>   /mnt/dx80_r5  ext4   defaults   0   2```
5. `chmod 777` auf Freigabeordner
5. `chown root:user`s auf Freigabeordner

## Samba konfigurieren
1. Freigabeordner erstellen und in Vorlage: smb.conf eintragen
12. `mv /etc/samba/smb.conf /etc/samba/smb.conf.backup`
12. smb.conf unter `/etc/samba/smb.conf` abspeichern
12. `sudo systemctl restart smbd`
