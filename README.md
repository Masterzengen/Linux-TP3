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

Contenu du .service:
```
[Unit]
Description=serverweb

[Service]
Type=simple
User=backup
Environment=PORT=8080
ExecStartPre=/usr/bin/sudo /usr/bin/firewall-cmd --add-port=${PORT}/tcp
ExecStart=/usr/bin/python -m SimpleHTTPServer ${PORT}
ExecStop=/usr/bin/sudo /usr/bin/firewall-cmd --remove-port=${PORT}/tcp




[Install]
WantedBy=multi-user.target
```          
Preuve du fonctionnement:
```  
[vagrant@localhost ~]$ sudo systemctl start web
[vagrant@localhost ~]$ sudo systemctl status web
● web.service - serverweb
   Loaded: loaded (/etc/systemd/system/web.service; disabled; vendor preset: disabled)
   Active: active (running) since Sat 2020-10-17 15:54:33 UTC; 5s ago
  Process: 2683 ExecStartPre=/usr/bin/sudo /usr/bin/firewall-cmd --add-port=${PORT}/tcp (code=exited, status=0/SUCCESS)
 Main PID: 2687 (python)
   CGroup: /system.slice/web.service
           └─2687 /usr/bin/python -m SimpleHTTPServer 8080

Oct 17 15:54:32 localhost.localdomain systemd[1]: Starting serverweb...
Oct 17 15:54:32 localhost.localdomain sudo[2683]:   backup : TTY=unknown ; PWD=/ ; USER=root ; COMMAND=/usr/bin/f.../tcp
Oct 17 15:54:33 localhost.localdomain systemd[1]: Started serverweb.
Hint: Some lines were ellipsized, use -l to show in full.
```  
Faire en sorte que le service se lance quand on boot la machine:
``` 
[vagrant@localhost ~]$ sudo systemctl enable web
``` 
Preuve du serveur web fonctionnel avec un curl
```
[vagrant@localhost ~]$ curl 192.168.10.21:8080
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2 Final//EN"><html>
<title>Directory listing for /</title>
<body>
<h2>Directory listing for /</h2>
<hr>
<ul>
<li><a href="bin/">bin@</a>
<li><a href="boot/">boot/</a>
<li><a href="dev/">dev/</a>
<li><a href="etc/">etc/</a>
<li><a href="home/">home/</a>
<li><a href="lib/">lib@</a>
<li><a href="lib64/">lib64@</a>
<li><a href="media/">media/</a>
<li><a href="mnt/">mnt/</a>
<li><a href="opt/">opt/</a>
<li><a href="proc/">proc/</a>
<li><a href="root/">root/</a>
<li><a href="run/">run/</a>
<li><a href="sbin/">sbin@</a>
<li><a href="srv/">srv/</a>
<li><a href="swapfile">swapfile</a>
<li><a href="sys/">sys/</a>
<li><a href="tmp/">tmp/</a>
<li><a href="usr/">usr/</a>
<li><a href="var/">var/</a>
</ul>
<hr>
</body>
</html>
```
## Sauvegarde



