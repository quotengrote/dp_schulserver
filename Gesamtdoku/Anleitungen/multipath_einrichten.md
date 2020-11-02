# dm-multipath mit Fujitsu Eternus DX80 einrichten

## Ziel
Die Eternus DX80 ist ein Plattenspeichersystem. Die Eternus DX80 ist hochverfügbar über zwei Controller über beide Ports des HBA (Host-Bus-Adapter, Verbindung von Geräten z.B. Speicher) angeschlossen. Dadurch werden dem OS (Operating System) zwei logische Geräte gezeigt, die jedoch das selbe Volume sind. Damit diese als ein logische Gerät verwendet werden können wird multipath in einer Active/Active-Konfiguration (mehrere Rechner sind gleichzeitig aktiv) verwendet.

### Bemerkungen und Quellen
- auf die Einrichtung des Storage wird in dieser Anleitung nicht weiter eingegangen
- Die Musterconfigurationsdateien befinden sich "neben" dieser Datei im Ordner.
  - [multipath.conf](../multipath.conf)
  - [wwids](../wwids)
- [RedHat](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/4/html/DM_Multipath/config_file_multipath.html)
- [GeekDiary](https://www.thegeekdiary.com/beginners-guide-to-device-mapper-dm-multipathing/)
- [Redhat 2](https://access.redhat.com/solutions/641083)
- [PVE Wiki](https://pve.proxmox.com/wiki/ISCSI_Multipath)
- [Icicimov](https://icicimov.github.io/blog/virtualization/Adding-iSCSI-shared-volume-to-Proxmox-to-support-Live-Migration/)

### Vorrausetzungen
- Storage eingerichtet
  - Volumes exportiert
  - Host Affinity gesetzt
  - Server ist doppelt an den Storage angeschlossen
    - 1x C(ontroller)M0 und 1x CM1
- PVE gemäß Anleitung eingerichtet

### Vorbereitung
1. pve auf aktuellen Stand bringen und notwendige Programme installieren
  > apt update && apt upgrade -y && apt install multipath-tools multipath-tools-boot dmsetup -y

2. Neustarten.

2. Identifizieren der Laufwerke anhand der WWN/WWID

  * `lsblk -o+wwn`

  - Da die Volumes doppelt angebunden sind muss folglich auch jede WWN 2x ausgegeben werden.

3. Setzen der Standardwerte/Modi der Anbindung
  > nano /etc/multipath.conf

 ```

 defaults {
              polling_interval        2
              path_selector           round-robin
              path_grouping_policy    multibus
              uid_attribute           ID_SERIAL
              rr_min_io_rq            1000
              failback                immediate
              no_path_retry           queue
              user_friendly_names     yes
              find_multipaths         no  #!!! https://www.suse.com/support/kb/doc/?id=7024049
            }
```


  - Siehe auch [Multipaths Device Configuration Attributes](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/4/html/DM_Multipath/config_file_multipath.html)
  - Option `find_multipaths = yes` heißt das nur Geräte verwendet werden die schon in `wwids` stehen.

3. "Blacklisten" der nicht zu verwendenen Laufwerke
> nano /etc/multipath.conf
```
      blacklist {
             devnode "^(ram|raw|loop|fd|md|dm-|sr|scd|st)[0-9]*"
             devnode "^(td|hd)[a-z]"
             devnode "^dcssblk[0-9]*"
             devnode "^cciss!c[0-9]d[0-9]*"
             device {
                     vendor "DGC"
                     product "LUNZ"
             }
             device {
                     vendor "EMC"
                     product "LUNZ"
             }
             device {
                     vendor "IBM"
                     product "Universal Xport"
             }
             device {
                     vendor "IBM"
                     product "S/390.*"
             }
             device {
                     vendor "DELL"
                     product "Universal Xport"
             }
             device {
                     vendor "SGI"
                     product "Universal Xport"
             }
             device {
                     vendor "STK"
                     product "Universal Xport"
             }
             device {
                     vendor "SUN"
                     product "Universal Xport"
             }
             device {
                     vendor "(NETAPP|LSI|ENGENIO)"
                     product "Universal Xport"
             }
           }
```
4. Setzen der Aliase für die Laufwerke
  > nano /etc/multipath.conf
```
    multipaths {
            wwid "0x600000e00d000000000109ea00000000"
            alias mpath0
      }
```
5. Setzen "Blacklist"-Ausnahmen
  > nano /etc/multipath.conf
```
  - Hier sind die in Schritt 2 ausgegeben WWN zu verwenden


    blacklist_exceptions {
            wwid "0x600000e00d000000000109ea00000000"
          }
```
6. Prüfen ob die WWNs in `wwids` stehen
  > nano /etc/multipath/wwids
```
  - Sollten die WWNs nicht in der Datei stehen sind sie in folgendem Format hinzuzufügen:

    ``/3600000e00d000000000109ea00010000/``  
```
8. Kernelmodule laden
  > modprobe -v dm_multipath

  > modprobe -v dm_round_robin

  (Ausgabe Beispiel: ``insmod /lib/modules/5.0.15-1-pve/kernel/drivers/md/dm-round-robin.ko`` )

9. Service neustarten
  > systemctl stop multipath-tools.service

(Warnung kann ignoriert werden)

  > systemctl start multipath-tools.service

  > systemctl status -l multipath-tools.service

7. prüfen ob multipath die Laufwerke zusammenfasst
  > multipath -ll

  - Sollten hierbei Fehler auftreten kann mit `multipath -v3` geprüft werden


### Bei Bedarf:
#### Wenn LVM genutzt wird/werden soll...
Dann muss ein Filter in ``/etc/lvm/lvm.conf`` gesetzt werden.
Dieser verhindert das PV nach dem Neustart von den `/dev/sd*` verwendet werden, anstatt der `/dev/mapper/mapath*`.
Werden nur die relativen Disk-Identifier genutzt kann ein PFadverlust nicht abgefangen werden da die Daten an Multipath vorbeilaufen.

##### Mögliche Lösung:

  > nano /etc/lvm/lvm.conf

```
global_filter = [ "r|/dev/zd.*|", "r|/dev/mapper/pve-.*|" "r|/dev/mapper/.*-(vm|base)--[0-9]+--disk--[0-9]+|"]
filter = [  "a|/dev/mapper/.*|", "a|/dev/sda.*|", "a|/dev/sdb.*|","r/.*/"  ]
```

#### LVM erstellen (nur bei PVE)
- PV: `pvcreate /dev/mapper/mpathX`
- VG: `vgcreate <Bezeichnung> /dev/mapper/mpathX`
- In PVE:
  WebGui -> Datacenter -> Storage -> Add -> LVM -> VG auswählen -> Fertig!

Befehele zu vg und pv: [Befehle](http://landoflinux.com/linux_lvm_command_examples.html)
### device excluded by a filter
1. prüfen welcher Fehler genau:
  > pvcreate /dev/mapper/mpathX -vvvv

2. lesen!
3. Bei Bedarf die ersten 512 Sektoren des Blockgeräte überschreiben:
  > dd if=/dev/zero of=/dev/mapper/mpathX bs=512 count=1 conv=notrunc

  > init 6
