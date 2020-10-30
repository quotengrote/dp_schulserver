#### Standardinstallation Proxmox
Zunächst einen bootfähigen Stick erstellen.

Dann den Stick vorm hochfahren einstecken und Powerbutton drücken.
- F12 drücken um in das Bootmenü zu gelangen, hier dann Stick auswählen (zum laden vom Stick)
- Dann Proxmox installieren:
Anleitung:
	1. Install Proxmox VE, mit Enter bestätigen
	1. EULA akzeptieren -> next
	1. Proxmox Virtualization Environment (PVE) -> next.
	1. Location and Time Zone Selection: Ausfüllen Land (Germany) (der Rest zieht sich dann selber, sonst Time Zone (Europe/Berlin))
	1. Keyboard Layout German -> next.
	1. Administration Passwort and E-Mail Address: Dann Passwort doppelt eingeben. Und EMail-Adresse von invalid auf valid stellen.
Management Network configuration: next
Summary: Install
Installation successful ->reboot
dann Stick ziehen
