# TP3
## Partie 1

Affichage du nombre de services systemd dispos sur la machine
```
sudo systemctl list-unit-files -t service -a | grep -c service
```
Affichage du nombre de services systemd actifs sur la machine
```
sudo systemctl -t service | grep -c running
```
Affichage du nombre de services systemd qui ont échoué
```
sudo systemctl -t service | grep -c failed
```
Affichage du nombre de services systemd qui démarrent automatiquement au boot
```
sudo systemctl list-unit-files -t service -a | grep -c enabled
```

## Partie 2: Analyse de service

Etudier le service nginx.service (path en commentaire)
```
systemctl cat nginx.service
```
Determiner le path de nginx.service via commande
```
systemctl status nginc.servcice
```
Résultat:
```
[vagrant@localhost ~]$ systemctl cat nginx.service
# /usr/lib/systemd/system/nginx.service
[Unit]
Description=The nginx HTTP and reverse proxy server
After=network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
# Nginx will fail to start if /run/nginx.pid already exists but has the wrong
# SELinux context. This might happen when running `nginx -t` from the cmdline.
# https://bugzilla.redhat.com/show_bug.cgi?id=1268621
ExecStartPre=/usr/bin/rm -f /run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGQUIT
TimeoutStopSec=5
KillMode=process
PrivateTmp=true

[Install]
WantedBy=multi-user.target

```

ExecStart: Il s'agit de la commande éffectuée lors de l'exécution de ce service

ExecStartPre: Il s'agit des commandes éffectuée avant celles lancées par ExecStart

PIDFile: Cette option permet de spécifier le chemin d'accès au fichier PID du service.

Type: Configure le type du ou des processus qui seront lancés par le service.

ExecReload: Indique la commande à effectuer pour lancer un reload du service.

Description: Le nom du service lisible et clair pour les devs.

After: Indique ce qui est nécéssaire d'être exécuté Pour le lancement du service et qui doit être lancé avant ce dernier.

Liste de tous les services qui contiennent la ligne WantedBy=multi-user.target
```
grep -r  /usr/lib/systemd/system -e WantedBy=multi-user.target
```
## Partie 3: Création de service
