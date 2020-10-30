### Startup-Script und Reset-Script einfügen und ausführen
Das Startup_Script.sh ist dafür zuständig 15 Schüler sowie 2 Lehrer und 2 Admin Accounts an zu legen. Es handelt sich hierbei um ein Bash-Shell-Script welches _copy/paste_ in `/usr/local/bin/` durch den Nutzers __root__ erstellt wird. Es ist hierbei darauf zu achten das die Variablen für die ISOs und den Storage genau wie die hochgeladenen Dateien bezeichnet sind um einen reibungslosen Ablauf des Scripts zu ermöglichen.

1. ISOs hochladen
	- über WebGUI
	local -> content -> Upload -> select file...

	Alternativ:
	- mit scp: `scp -r <quelle> user@host:ziel`

	Beispiel:
	`scp -r C:\Users\Nutzer\Dokumente\ISO\iso root@192.168.137.1:/var/lib/vz/template`

	Dazu gehören:
	- Ubuntu
	- Windows
	- VirtIO
	- Windows Server

1. Dateien erstellen
	`nano /usr/local/bin/startup_bbsovg.sh`
	`nano /usr/local/bin/reset_VMs.sh`

1. Mit Copy/Paste Skripte im Ordner Scripte kopieren
Note: In der Datei startup_bbsovg.sh Passwörter hinterlegen.

1. Scripte ausführbar machen
	`chmod +x /usr/local/bin/startup_bbsovg.sh`
	`chmod +x /usr/local/bin/reset_VMs.sh`

1. Script Ausführen
	`startup_bbsovg.sh`

Das _reset_VMs.sh_ Script wird hierbei vom Lehrer nach erfolgter Stunde ausgeführt damit fertig installierte VMs auf den Startup stand zurück gesetzt werden. Es werden hierbei alle VMs (3 pro Pool bzw Schüleraccount) zurückgesetzt.
