# IPs fest mit netplan setzen

* netplan arbeitet Dateien in numerischer Reihenfolge ab.
  * Daher vorher prüfen welche Dateien in `/etc/netplan` liegen und die eigene Konfiguration mir einer kleineren Nummer versehen.
* netplan Dateien sind yaml, sprich die Struktur der Datei basiert auf Einrückungen.
  * Zur Bearbeitung wird daher `vi` empfohlen da hier die Einrückungen korrekt unterstützt werden.

## Konfiguration
* Pfad: `/etc/netplan/10-static-bbs.yml`

### Inhalt
```
network:
        version: 2
        renderer: networkd
        ethernets:
                <Interfacebezeichnung>:
                        addresses:
                                - <IP>/<Subnetzmaske>
                        gateway4: <IP>

```
## Konfiguration anwenden
* `netplan try` <-- versucht die Änderungen anzuwenden
* `netplan apply` <-- wendet die Änderungen sofort an
