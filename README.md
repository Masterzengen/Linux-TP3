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

## Autres features

Diagramme SVG avec la commande systemd-analyze plot
```
[vagrant@localhost ~]$ systemd-analyze plot
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg width="1833px" height="2310px" version="1.1" xmlns="http://www.w3.org/2000/svg">

<!-- This file is a systemd-analyze SVG file. It is best rendered in a   -->
<!-- browser such as Chrome, Chromium or Firefox. Other applications     -->
<!-- that render these files properly but much slower are ImageMagick,   -->
<!-- gimp, inkscape, etc. To display the files on your system, just      -->
<!-- point your browser to this file.                                    -->

<!-- This plot was generated by systemd-analyze version 219              -->

<defs>
  <style type="text/css">
    <![CDATA[
      rect       { stroke-width: 1; stroke-opacity: 0; }
      rect.background   { fill: rgb(255,255,255); }
      rect.activating   { fill: rgb(255,0,0); fill-opacity: 0.7; }
      rect.active       { fill: rgb(200,150,150); fill-opacity: 0.7; }
      rect.deactivating { fill: rgb(150,100,100); fill-opacity: 0.7; }
      rect.kernel       { fill: rgb(150,150,150); fill-opacity: 0.7; }
      rect.initrd       { fill: rgb(150,150,150); fill-opacity: 0.7; }
      rect.firmware     { fill: rgb(150,150,150); fill-opacity: 0.7; }
      rect.loader       { fill: rgb(150,150,150); fill-opacity: 0.7; }
      rect.userspace    { fill: rgb(150,150,150); fill-opacity: 0.7; }
      rect.security     { fill: rgb(144,238,144); fill-opacity: 0.7; }
      rect.generators   { fill: rgb(102,204,255); fill-opacity: 0.7; }
      rect.unitsload    { fill: rgb( 82,184,255); fill-opacity: 0.7; }
      rect.box   { fill: rgb(240,240,240); stroke: rgb(192,192,192); }
      line       { stroke: rgb(64,64,64); stroke-width: 1; }
//    line.sec1  { }
      line.sec5  { stroke-width: 2; }
      line.sec01 { stroke: rgb(224,224,224); stroke-width: 1; }
      text       { font-family: Verdana, Helvetica; font-size: 14px; }
      text.left  { font-family: Verdana, Helvetica; font-size: 14px; text-anchor: start; }
      text.right { font-family: Verdana, Helvetica; font-size: 14px; text-anchor: end; }
      text.sec   { font-size: 10px; }
    ]]>
   </style>
</defs>

<rect class="background" width="100%" height="100%" />
<text x="20" y="50">Startup finished in 588ms (kernel) + 832ms (initrd) + 16.112s (userspace) = 17.533s</text><text x="20" y="30">CentOS Linux 7 (Core) localhost.localdomain (Linux 3.10.0-1127.19.1.el7.x86_64 #1 SMP Tue Aug 25 17:23:54 UTC 2020) x86-64 kvm</text><g transform="translate(20.000,100)">
<rect class="box" x="0" y="0" width="1753.330" height="2060.000" />
  <line class="sec5" x1="0.000" y1="0" x2="0.000" y2="2060.000" />
  <text class="sec" x="0.000" y="-5.000" >0.0s</text>
  <line class="sec01" x1="10.000" y1="0" x2="10.000" y2="2060.000" />
  <line class="sec01" x1="20.000" y1="0" x2="20.000" y2="2060.000" />
  <line class="sec01" x1="30.000" y1="0" x2="30.000" y2="2060.000" />
  <line class="sec01" x1="40.000" y1="0" x2="40.000" y2="2060.000" />
  <line class="sec01" x1="50.000" y1="0" x2="50.000" y2="2060.000" />
  <line class="sec01" x1="60.000" y1="0" x2="60.000" y2="2060.000" />
  <line class="sec01" x1="70.000" y1="0" x2="70.000" y2="2060.000" />
  <line class="sec01" x1="80.000" y1="0" x2="80.000" y2="2060.000" />
  <line class="sec01" x1="90.000" y1="0" x2="90.000" y2="2060.000" />
  <line class="sec1" x1="100.000" y1="0" x2="100.000" y2="2060.000" />
  <text class="sec" x="100.000" y="-5.000" >1.0s</text>
  <line class="sec01" x1="110.000" y1="0" x2="110.000" y2="2060.000" />
  <line class="sec01" x1="120.000" y1="0" x2="120.000" y2="2060.000" />
  <line class="sec01" x1="130.000" y1="0" x2="130.000" y2="2060.000" />
  <line class="sec01" x1="140.000" y1="0" x2="140.000" y2="2060.000" />
  <line class="sec01" x1="150.000" y1="0" x2="150.000" y2="2060.000" />
  <line class="sec01" x1="160.000" y1="0" x2="160.000" y2="2060.000" />
  <line class="sec01" x1="170.000" y1="0" x2="170.000" y2="2060.000" />
  <line class="sec01" x1="180.000" y1="0" x2="180.000" y2="2060.000" />
  <line class="sec01" x1="190.000" y1="0" x2="190.000" y2="2060.000" />
  <line class="sec1" x1="200.000" y1="0" x2="200.000" y2="2060.000" />
  <text class="sec" x="200.000" y="-5.000" >2.0s</text>
  <line class="sec01" x1="210.000" y1="0" x2="210.000" y2="2060.000" />
  <line class="sec01" x1="220.000" y1="0" x2="220.000" y2="2060.000" />
  <line class="sec01" x1="230.000" y1="0" x2="230.000" y2="2060.000" />
  <line class="sec01" x1="240.000" y1="0" x2="240.000" y2="2060.000" />
  <line class="sec01" x1="250.000" y1="0" x2="250.000" y2="2060.000" />
  <line class="sec01" x1="260.000" y1="0" x2="260.000" y2="2060.000" />
  <line class="sec01" x1="270.000" y1="0" x2="270.000" y2="2060.000" />
  <line class="sec01" x1="280.000" y1="0" x2="280.000" y2="2060.000" />
  <line class="sec01" x1="290.000" y1="0" x2="290.000" y2="2060.000" />
  <line class="sec1" x1="300.000" y1="0" x2="300.000" y2="2060.000" />
  <text class="sec" x="300.000" y="-5.000" >3.0s</text>
  <line class="sec01" x1="310.000" y1="0" x2="310.000" y2="2060.000" />
  <line class="sec01" x1="320.000" y1="0" x2="320.000" y2="2060.000" />
  <line class="sec01" x1="330.000" y1="0" x2="330.000" y2="2060.000" />
  <line class="sec01" x1="340.000" y1="0" x2="340.000" y2="2060.000" />
  <line class="sec01" x1="350.000" y1="0" x2="350.000" y2="2060.000" />
  <line class="sec01" x1="360.000" y1="0" x2="360.000" y2="2060.000" />
  <line class="sec01" x1="370.000" y1="0" x2="370.000" y2="2060.000" />
  <line class="sec01" x1="380.000" y1="0" x2="380.000" y2="2060.000" />
  <line class="sec01" x1="390.000" y1="0" x2="390.000" y2="2060.000" />
  <line class="sec1" x1="400.000" y1="0" x2="400.000" y2="2060.000" />
  <text class="sec" x="400.000" y="-5.000" >4.0s</text>
  <line class="sec01" x1="410.000" y1="0" x2="410.000" y2="2060.000" />
  <line class="sec01" x1="420.000" y1="0" x2="420.000" y2="2060.000" />
  <line class="sec01" x1="430.000" y1="0" x2="430.000" y2="2060.000" />
  <line class="sec01" x1="440.000" y1="0" x2="440.000" y2="2060.000" />
  <line class="sec01" x1="450.000" y1="0" x2="450.000" y2="2060.000" />
  <line class="sec01" x1="460.000" y1="0" x2="460.000" y2="2060.000" />
  <line class="sec01" x1="470.000" y1="0" x2="470.000" y2="2060.000" />
  <line class="sec01" x1="480.000" y1="0" x2="480.000" y2="2060.000" />
  <line class="sec01" x1="490.000" y1="0" x2="490.000" y2="2060.000" />
  <line class="sec5" x1="500.000" y1="0" x2="500.000" y2="2060.000" />
  <text class="sec" x="500.000" y="-5.000" >5.0s</text>
  <line class="sec01" x1="510.000" y1="0" x2="510.000" y2="2060.000" />
  <line class="sec01" x1="520.000" y1="0" x2="520.000" y2="2060.000" />
  <line class="sec01" x1="530.000" y1="0" x2="530.000" y2="2060.000" />
  <line class="sec01" x1="540.000" y1="0" x2="540.000" y2="2060.000" />
  <line class="sec01" x1="550.000" y1="0" x2="550.000" y2="2060.000" />
  <line class="sec01" x1="560.000" y1="0" x2="560.000" y2="2060.000" />
  <line class="sec01" x1="570.000" y1="0" x2="570.000" y2="2060.000" />
  <line class="sec01" x1="580.000" y1="0" x2="580.000" y2="2060.000" />
  <line class="sec01" x1="590.000" y1="0" x2="590.000" y2="2060.000" />
  <line class="sec1" x1="600.000" y1="0" x2="600.000" y2="2060.000" />
  <text class="sec" x="600.000" y="-5.000" >6.0s</text>
  <line class="sec01" x1="610.000" y1="0" x2="610.000" y2="2060.000" />
  <line class="sec01" x1="620.000" y1="0" x2="620.000" y2="2060.000" />
  <line class="sec01" x1="630.000" y1="0" x2="630.000" y2="2060.000" />
  <line class="sec01" x1="640.000" y1="0" x2="640.000" y2="2060.000" />
  <line class="sec01" x1="650.000" y1="0" x2="650.000" y2="2060.000" />
  <line class="sec01" x1="660.000" y1="0" x2="660.000" y2="2060.000" />
  <line class="sec01" x1="670.000" y1="0" x2="670.000" y2="2060.000" />
  <line class="sec01" x1="680.000" y1="0" x2="680.000" y2="2060.000" />
  <line class="sec01" x1="690.000" y1="0" x2="690.000" y2="2060.000" />
  <line class="sec1" x1="700.000" y1="0" x2="700.000" y2="2060.000" />
  <text class="sec" x="700.000" y="-5.000" >7.0s</text>
  <line class="sec01" x1="710.000" y1="0" x2="710.000" y2="2060.000" />
  <line class="sec01" x1="720.000" y1="0" x2="720.000" y2="2060.000" />
  <line class="sec01" x1="730.000" y1="0" x2="730.000" y2="2060.000" />
  <line class="sec01" x1="740.000" y1="0" x2="740.000" y2="2060.000" />
  <line class="sec01" x1="750.000" y1="0" x2="750.000" y2="2060.000" />
  <line class="sec01" x1="760.000" y1="0" x2="760.000" y2="2060.000" />
  <line class="sec01" x1="770.000" y1="0" x2="770.000" y2="2060.000" />
  <line class="sec01" x1="780.000" y1="0" x2="780.000" y2="2060.000" />
  <line class="sec01" x1="790.000" y1="0" x2="790.000" y2="2060.000" />
  <line class="sec1" x1="800.000" y1="0" x2="800.000" y2="2060.000" />
  <text class="sec" x="800.000" y="-5.000" >8.0s</text>
  <line class="sec01" x1="810.000" y1="0" x2="810.000" y2="2060.000" />
  <line class="sec01" x1="820.000" y1="0" x2="820.000" y2="2060.000" />
  <line class="sec01" x1="830.000" y1="0" x2="830.000" y2="2060.000" />
  <line class="sec01" x1="840.000" y1="0" x2="840.000" y2="2060.000" />
  <line class="sec01" x1="850.000" y1="0" x2="850.000" y2="2060.000" />
  <line class="sec01" x1="860.000" y1="0" x2="860.000" y2="2060.000" />
  <line class="sec01" x1="870.000" y1="0" x2="870.000" y2="2060.000" />
  <line class="sec01" x1="880.000" y1="0" x2="880.000" y2="2060.000" />
  <line class="sec01" x1="890.000" y1="0" x2="890.000" y2="2060.000" />
  <line class="sec1" x1="900.000" y1="0" x2="900.000" y2="2060.000" />
  <text class="sec" x="900.000" y="-5.000" >9.0s</text>
  <line class="sec01" x1="910.000" y1="0" x2="910.000" y2="2060.000" />
  <line class="sec01" x1="920.000" y1="0" x2="920.000" y2="2060.000" />
  <line class="sec01" x1="930.000" y1="0" x2="930.000" y2="2060.000" />
  <line class="sec01" x1="940.000" y1="0" x2="940.000" y2="2060.000" />
  <line class="sec01" x1="950.000" y1="0" x2="950.000" y2="2060.000" />
  <line class="sec01" x1="960.000" y1="0" x2="960.000" y2="2060.000" />
  <line class="sec01" x1="970.000" y1="0" x2="970.000" y2="2060.000" />
  <line class="sec01" x1="980.000" y1="0" x2="980.000" y2="2060.000" />
  <line class="sec01" x1="990.000" y1="0" x2="990.000" y2="2060.000" />
  <line class="sec5" x1="1000.000" y1="0" x2="1000.000" y2="2060.000" />
  <text class="sec" x="1000.000" y="-5.000" >10.0s</text>
  <line class="sec01" x1="1010.000" y1="0" x2="1010.000" y2="2060.000" />
  <line class="sec01" x1="1020.000" y1="0" x2="1020.000" y2="2060.000" />
  <line class="sec01" x1="1030.000" y1="0" x2="1030.000" y2="2060.000" />
  <line class="sec01" x1="1040.000" y1="0" x2="1040.000" y2="2060.000" />
  <line class="sec01" x1="1050.000" y1="0" x2="1050.000" y2="2060.000" />
  <line class="sec01" x1="1060.000" y1="0" x2="1060.000" y2="2060.000" />
  <line class="sec01" x1="1070.000" y1="0" x2="1070.000" y2="2060.000" />
  <line class="sec01" x1="1080.000" y1="0" x2="1080.000" y2="2060.000" />
  <line class="sec01" x1="1090.000" y1="0" x2="1090.000" y2="2060.000" />
  <line class="sec1" x1="1100.000" y1="0" x2="1100.000" y2="2060.000" />
  <text class="sec" x="1100.000" y="-5.000" >11.0s</text>
  <line class="sec01" x1="1110.000" y1="0" x2="1110.000" y2="2060.000" />
  <line class="sec01" x1="1120.000" y1="0" x2="1120.000" y2="2060.000" />
  <line class="sec01" x1="1130.000" y1="0" x2="1130.000" y2="2060.000" />
  <line class="sec01" x1="1140.000" y1="0" x2="1140.000" y2="2060.000" />
  <line class="sec01" x1="1150.000" y1="0" x2="1150.000" y2="2060.000" />
  <line class="sec01" x1="1160.000" y1="0" x2="1160.000" y2="2060.000" />
  <line class="sec01" x1="1170.000" y1="0" x2="1170.000" y2="2060.000" />
  <line class="sec01" x1="1180.000" y1="0" x2="1180.000" y2="2060.000" />
  <line class="sec01" x1="1190.000" y1="0" x2="1190.000" y2="2060.000" />
  <line class="sec1" x1="1200.000" y1="0" x2="1200.000" y2="2060.000" />
  <text class="sec" x="1200.000" y="-5.000" >12.0s</text>
  <line class="sec01" x1="1210.000" y1="0" x2="1210.000" y2="2060.000" />
  <line class="sec01" x1="1220.000" y1="0" x2="1220.000" y2="2060.000" />
  <line class="sec01" x1="1230.000" y1="0" x2="1230.000" y2="2060.000" />
  <line class="sec01" x1="1240.000" y1="0" x2="1240.000" y2="2060.000" />
  <line class="sec01" x1="1250.000" y1="0" x2="1250.000" y2="2060.000" />
  <line class="sec01" x1="1260.000" y1="0" x2="1260.000" y2="2060.000" />
  <line class="sec01" x1="1270.000" y1="0" x2="1270.000" y2="2060.000" />
  <line class="sec01" x1="1280.000" y1="0" x2="1280.000" y2="2060.000" />
  <line class="sec01" x1="1290.000" y1="0" x2="1290.000" y2="2060.000" />
  <line class="sec1" x1="1300.000" y1="0" x2="1300.000" y2="2060.000" />
  <text class="sec" x="1300.000" y="-5.000" >13.0s</text>
  <line class="sec01" x1="1310.000" y1="0" x2="1310.000" y2="2060.000" />
  <line class="sec01" x1="1320.000" y1="0" x2="1320.000" y2="2060.000" />
  <line class="sec01" x1="1330.000" y1="0" x2="1330.000" y2="2060.000" />
  <line class="sec01" x1="1340.000" y1="0" x2="1340.000" y2="2060.000" />
  <line class="sec01" x1="1350.000" y1="0" x2="1350.000" y2="2060.000" />
  <line class="sec01" x1="1360.000" y1="0" x2="1360.000" y2="2060.000" />
  <line class="sec01" x1="1370.000" y1="0" x2="1370.000" y2="2060.000" />
  <line class="sec01" x1="1380.000" y1="0" x2="1380.000" y2="2060.000" />
  <line class="sec01" x1="1390.000" y1="0" x2="1390.000" y2="2060.000" />
  <line class="sec1" x1="1400.000" y1="0" x2="1400.000" y2="2060.000" />
  <text class="sec" x="1400.000" y="-5.000" >14.0s</text>
  <line class="sec01" x1="1410.000" y1="0" x2="1410.000" y2="2060.000" />
  <line class="sec01" x1="1420.000" y1="0" x2="1420.000" y2="2060.000" />
  <line class="sec01" x1="1430.000" y1="0" x2="1430.000" y2="2060.000" />
  <line class="sec01" x1="1440.000" y1="0" x2="1440.000" y2="2060.000" />
  <line class="sec01" x1="1450.000" y1="0" x2="1450.000" y2="2060.000" />
  <line class="sec01" x1="1460.000" y1="0" x2="1460.000" y2="2060.000" />
  <line class="sec01" x1="1470.000" y1="0" x2="1470.000" y2="2060.000" />
  <line class="sec01" x1="1480.000" y1="0" x2="1480.000" y2="2060.000" />
  <line class="sec01" x1="1490.000" y1="0" x2="1490.000" y2="2060.000" />
  <line class="sec5" x1="1500.000" y1="0" x2="1500.000" y2="2060.000" />
  <text class="sec" x="1500.000" y="-5.000" >15.0s</text>
  <line class="sec01" x1="1510.000" y1="0" x2="1510.000" y2="2060.000" />
  <line class="sec01" x1="1520.000" y1="0" x2="1520.000" y2="2060.000" />
  <line class="sec01" x1="1530.000" y1="0" x2="1530.000" y2="2060.000" />
  <line class="sec01" x1="1540.000" y1="0" x2="1540.000" y2="2060.000" />
  <line class="sec01" x1="1550.000" y1="0" x2="1550.000" y2="2060.000" />
  <line class="sec01" x1="1560.000" y1="0" x2="1560.000" y2="2060.000" />
  <line class="sec01" x1="1570.000" y1="0" x2="1570.000" y2="2060.000" />
  <line class="sec01" x1="1580.000" y1="0" x2="1580.000" y2="2060.000" />
  <line class="sec01" x1="1590.000" y1="0" x2="1590.000" y2="2060.000" />
  <line class="sec1" x1="1600.000" y1="0" x2="1600.000" y2="2060.000" />
  <text class="sec" x="1600.000" y="-5.000" >16.0s</text>
  <line class="sec01" x1="1610.000" y1="0" x2="1610.000" y2="2060.000" />
  <line class="sec01" x1="1620.000" y1="0" x2="1620.000" y2="2060.000" />
  <line class="sec01" x1="1630.000" y1="0" x2="1630.000" y2="2060.000" />
  <line class="sec01" x1="1640.000" y1="0" x2="1640.000" y2="2060.000" />
  <line class="sec01" x1="1650.000" y1="0" x2="1650.000" y2="2060.000" />
  <line class="sec01" x1="1660.000" y1="0" x2="1660.000" y2="2060.000" />
  <line class="sec01" x1="1670.000" y1="0" x2="1670.000" y2="2060.000" />
  <line class="sec01" x1="1680.000" y1="0" x2="1680.000" y2="2060.000" />
  <line class="sec01" x1="1690.000" y1="0" x2="1690.000" y2="2060.000" />
  <line class="sec1" x1="1700.000" y1="0" x2="1700.000" y2="2060.000" />
  <text class="sec" x="1700.000" y="-5.000" >17.0s</text>
  <line class="sec01" x1="1710.000" y1="0" x2="1710.000" y2="2060.000" />
  <line class="sec01" x1="1720.000" y1="0" x2="1720.000" y2="2060.000" />
  <line class="sec01" x1="1730.000" y1="0" x2="1730.000" y2="2060.000" />
  <line class="sec01" x1="1740.000" y1="0" x2="1740.000" y2="2060.000" />
  <line class="sec01" x1="1750.000" y1="0" x2="1750.000" y2="2060.000" />
  <rect class="kernel" x="0.000" y="0.000" width="58.824" height="19.000" />
  <text class="left" x="5.000" y="14.000">kernel</text>
  <rect class="initrd" x="58.824" y="20.000" width="83.273" height="19.000" />
  <text class="left" x="63.824" y="34.000">initrd</text>
  <rect class="active" x="142.097" y="40.000" width="1611.232" height="19.000" />
  <rect class="security" x="142.492" y="40.000" width="16.711" height="19.000" />
  <rect class="generators" x="166.317" y="40.000" width="3.069" height="19.000" />
  <rect class="unitsload" x="169.557" y="40.000" width="18.436" height="19.000" />
  <text class="left" x="147.097" y="54.000">systemd</text>
  <rect class="activating" x="189.064" y="60.000" width="9.518" height="19.000" />
  <rect class="active" x="198.582" y="60.000" width="1554.747" height="19.000" />
  <rect class="deactivating" x="1753.330" y="60.000" width="0.000" height="19.000" />
  <text class="left" x="194.064" y="74.000">systemd-journald.service (95ms)</text>
  <rect class="activating" x="189.072" y="80.000" width="0.000" height="19.000" />
  <rect class="active" x="189.072" y="80.000" width="1564.257" height="19.000" />
  <rect class="deactivating" x="1753.330" y="80.000" width="0.000" height="19.000" />
  <text class="left" x="194.072" y="94.000">cryptsetup.target</text>
  <rect class="activating" x="189.458" y="100.000" width="0.000" height="19.000" />
  <rect class="active" x="189.458" y="100.000" width="1563.871" height="19.000" />
  <rect class="deactivating" x="1753.330" y="100.000" width="0.000" height="19.000" />
  <text class="left" x="194.458" y="114.000">systemd-udevd-control.socket</text>
  <rect class="activating" x="189.610" y="120.000" width="0.000" height="19.000" />
  <rect class="active" x="189.610" y="120.000" width="1563.719" height="19.000" />
  <rect class="deactivating" x="1753.330" y="120.000" width="0.000" height="19.000" />
  <text class="left" x="194.610" y="134.000">systemd-initctl.socket</text>
  <rect class="activating" x="189.888" y="140.000" width="9.957" height="19.000" />
  <rect class="active" x="199.844" y="140.000" width="1553.485" height="19.000" />
  <rect class="deactivating" x="1753.330" y="140.000" width="0.000" height="19.000" />
  <text class="left" x="194.888" y="154.000">kmod-static-nodes.service (99ms)</text>
  <rect class="activating" x="190.056" y="160.000" width="0.000" height="19.000" />
  <rect class="active" x="190.056" y="160.000" width="1563.274" height="19.000" />
  <rect class="deactivating" x="1753.330" y="160.000" width="0.000" height="19.000" />
  <text class="left" x="195.056" y="174.000">systemd-shutdownd.socket</text>
  <rect class="activating" x="190.073" y="180.000" width="0.000" height="19.000" />
  <rect class="active" x="190.073" y="180.000" width="1563.256" height="19.000" />
  <rect class="deactivating" x="1753.330" y="180.000" width="0.000" height="19.000" />
  <text class="left" x="195.073" y="194.000">rpcbind.target</text>
  <rect class="activating" x="190.400" y="200.000" width="6.803" height="19.000" />
  <rect class="active" x="197.203" y="200.000" width="1556.127" height="19.000" />
  <rect class="deactivating" x="1753.330" y="200.000" width="0.000" height="19.000" />
  <text class="left" x="195.400" y="214.000">sys-kernel-debug.mount (68ms)</text>
  <rect class="activating" x="190.574" y="220.000" width="0.000" height="19.000" />
  <rect class="active" x="190.574" y="220.000" width="1562.756" height="19.000" />
  <rect class="deactivating" x="1753.330" y="220.000" width="0.000" height="19.000" />
  <text class="left" x="195.574" y="234.000">systemd-udevd-kernel.socket</text>
  <rect class="activating" x="190.597" y="240.000" width="0.000" height="19.000" />
  <rect class="active" x="190.597" y="240.000" width="1562.733" height="19.000" />
  <rect class="deactivating" x="1753.330" y="240.000" width="0.000" height="19.000" />
  <text class="left" x="195.597" y="254.000">systemd-ask-password-console.path</text>
  <rect class="activating" x="190.809" y="260.000" width="9.616" height="19.000" />
  <rect class="active" x="200.425" y="260.000" width="1552.905" height="19.000" />
  <rect class="deactivating" x="1753.330" y="260.000" width="0.000" height="19.000" />
  <text class="left" x="195.809" y="274.000">rhel-domainname.service (96ms)</text>
  <rect class="activating" x="192.867" y="280.000" width="0.000" height="19.000" />
  <rect class="active" x="192.867" y="280.000" width="1560.463" height="19.000" />
  <rect class="deactivating" x="1753.330" y="280.000" width="0.000" height="19.000" />
  <text class="left" x="197.867" y="294.000">user.slice</text>
  <rect class="activating" x="193.151" y="300.000" width="0.000" height="19.000" />
  <rect class="active" x="193.151" y="300.000" width="1560.179" height="19.000" />
  <rect class="deactivating" x="1753.330" y="300.000" width="0.000" height="19.000" />
  <text class="left" x="198.151" y="314.000">systemd-ask-password-wall.path</text>
  <rect class="activating" x="193.155" y="320.000" width="0.000" height="19.000" />
  <rect class="active" x="193.155" y="320.000" width="1560.175" height="19.000" />
  <rect class="deactivating" x="1753.330" y="320.000" width="0.000" height="19.000" />
  <text class="left" x="198.155" y="334.000">paths.target</text>
  <rect class="activating" x="193.219" y="340.000" width="0.000" height="19.000" />
  <rect class="active" x="193.219" y="340.000" width="1560.111" height="19.000" />
  <rect class="deactivating" x="1753.330" y="340.000" width="0.000" height="19.000" />
  <text class="left" x="198.219" y="354.000">proc-sys-fs-binfmt_misc.automount</text>
  <rect class="activating" x="193.436" y="360.000" width="0.000" height="19.000" />
  <rect class="active" x="193.436" y="360.000" width="1559.894" height="19.000" />
  <rect class="deactivating" x="1753.330" y="360.000" width="0.000" height="19.000" />
  <text class="left" x="198.436" y="374.000">system-getty.slice</text>
  <rect class="activating" x="193.867" y="380.000" width="4.620" height="19.000" />
  <rect class="active" x="198.486" y="380.000" width="1554.843" height="19.000" />
  <rect class="deactivating" x="1753.330" y="380.000" width="0.000" height="19.000" />
  <text class="left" x="198.867" y="394.000">dev-hugepages.mount (46ms)</text>
  <rect class="activating" x="193.875" y="400.000" width="0.000" height="19.000" />
  <rect class="active" x="193.875" y="400.000" width="1559.455" height="19.000" />
  <rect class="deactivating" x="1753.330" y="400.000" width="0.000" height="19.000" />
  <text class="left" x="198.875" y="414.000">slices.target</text>
  <rect class="activating" x="194.522" y="420.000" width="6.306" height="19.000" />
  <rect class="active" x="200.827" y="420.000" width="1552.502" height="19.000" />
  <rect class="deactivating" x="1753.330" y="420.000" width="0.000" height="19.000" />
  <text class="left" x="199.522" y="434.000">systemd-remount-fs.service (63ms)</text>
  <rect class="activating" x="195.247" y="440.000" width="117.956" height="19.000" />
  <rect class="active" x="313.203" y="440.000" width="1440.126" height="19.000" />
  <rect class="deactivating" x="1753.330" y="440.000" width="0.000" height="19.000" />
  <text class="left" x="200.247" y="454.000">systemd-vconsole-setup.service (1.179s)</text>
  <rect class="activating" x="195.665" y="460.000" width="0.000" height="19.000" />
  <rect class="active" x="195.665" y="460.000" width="1557.664" height="19.000" />
  <rect class="deactivating" x="1753.330" y="460.000" width="0.000" height="19.000" />
  <text class="left" x="200.665" y="474.000">system-selinux\x2dpolicy\x2dmigrate\x2dlocal\x2dchanges.slice</text>
  <rect class="activating" x="195.851" y="480.000" width="5.107" height="19.000" />
  <rect class="active" x="200.958" y="480.000" width="1552.371" height="19.000" />
  <rect class="deactivating" x="1753.330" y="480.000" width="0.000" height="19.000" />
  <text class="left" x="200.851" y="494.000">systemd-sysctl.service (51ms)</text>
  <rect class="activating" x="197.095" y="500.000" width="1.387" height="19.000" />
  <rect class="active" x="198.482" y="500.000" width="1554.848" height="19.000" />
  <rect class="deactivating" x="1753.330" y="500.000" width="0.000" height="19.000" />
  <text class="left" x="202.095" y="514.000">dev-mqueue.mount (13ms)</text>
  <rect class="activating" x="197.168" y="520.000" width="97.189" height="19.000" />
  <rect class="active" x="294.357" y="520.000" width="1458.972" height="19.000" />
  <rect class="deactivating" x="1753.330" y="520.000" width="0.000" height="19.000" />
  <text class="left" x="202.168" y="534.000">dev-sda1.device (971ms)</text>
  <rect class="activating" x="201.311" y="540.000" width="24.453" height="19.000" />
  <rect class="active" x="225.764" y="540.000" width="1527.566" height="19.000" />
  <rect class="deactivating" x="1753.330" y="540.000" width="0.000" height="19.000" />
  <text class="left" x="206.311" y="554.000">systemd-udev-trigger.service (244ms)</text>
  <rect class="activating" x="201.419" y="560.000" width="132.101" height="19.000" />
  <rect class="active" x="333.520" y="560.000" width="1419.809" height="19.000" />
  <rect class="deactivating" x="1753.330" y="560.000" width="0.000" height="19.000" />
  <text class="left" x="206.419" y="574.000">swapfile.swap (1.321s)</text>
  <rect class="activating" x="205.514" y="580.000" width="12.962" height="19.000" />
  <rect class="active" x="218.476" y="580.000" width="1534.854" height="19.000" />
  <rect class="deactivating" x="1753.330" y="580.000" width="0.000" height="19.000" />
  <text class="left" x="210.514" y="594.000">rhel-readonly.service (129ms)</text>
  <rect class="activating" x="205.728" y="600.000" width="10.618" height="19.000" />
  <rect class="active" x="216.345" y="600.000" width="1536.984" height="19.000" />
  <rect class="deactivating" x="1753.330" y="600.000" width="0.000" height="19.000" />
  <text class="left" x="210.728" y="614.000">systemd-tmpfiles-setup-dev.service (106ms)</text>
  <rect class="activating" x="205.804" y="620.000" width="3.726" height="19.000" />
  <rect class="active" x="209.531" y="620.000" width="1543.799" height="19.000" />
  <rect class="deactivating" x="1753.330" y="620.000" width="0.000" height="19.000" />
  <text class="left" x="210.804" y="634.000">systemd-journal-flush.service (37ms)</text>
  <rect class="activating" x="216.458" y="640.000" width="14.274" height="19.000" />
  <rect class="active" x="230.732" y="640.000" width="1522.598" height="19.000" />
  <rect class="deactivating" x="1753.330" y="640.000" width="0.000" height="19.000" />
  <text class="left" x="221.458" y="654.000">systemd-udevd.service (142ms)</text>
  <rect class="activating" x="216.482" y="660.000" width="0.000" height="19.000" />
  <rect class="active" x="216.482" y="660.000" width="1536.848" height="19.000" />
  <rect class="deactivating" x="1753.330" y="660.000" width="0.000" height="19.000" />
  <text class="left" x="221.482" y="674.000">local-fs-pre.target</text>
  <rect class="activating" x="218.569" y="680.000" width="3.249" height="19.000" />
  <rect class="active" x="221.818" y="680.000" width="1531.512" height="19.000" />
  <rect class="deactivating" x="1753.330" y="680.000" width="0.000" height="19.000" />
  <text class="left" x="223.569" y="694.000">systemd-random-seed.service (32ms)</text>
  <rect class="activating" x="218.593" y="700.000" width="0.000" height="19.000" />
  <rect class="active" x="218.593" y="700.000" width="1534.736" height="19.000" />
  <rect class="deactivating" x="1753.330" y="700.000" width="0.000" height="19.000" />
  <text class="left" x="223.593" y="714.000">local-fs.target</text>
  <rect class="activating" x="219.045" y="720.000" width="2.436" height="19.000" />
  <rect class="active" x="221.481" y="720.000" width="0.000" height="19.000" />
  <rect class="deactivating" x="221.481" y="720.000" width="0.000" height="19.000" />
  <text class="left" x="224.045" y="734.000">selinux-policy-migrate-local-changes@targeted.service (24ms)</text>
  <rect class="activating" x="219.126" y="740.000" width="6.147" height="19.000" />
  <rect class="active" x="225.273" y="740.000" width="0.000" height="19.000" />
  <rect class="deactivating" x="225.273" y="740.000" width="0.000" height="19.000" />
  <text class="left" x="224.126" y="754.000">nfs-config.service (61ms)</text>
  <rect class="activating" x="220.008" y="760.000" width="15.514" height="19.000" />
  <rect class="active" x="235.522" y="760.000" width="1517.808" height="19.000" />
  <rect class="deactivating" x="1753.330" y="760.000" width="0.000" height="19.000" />
  <text class="left" x="225.008" y="774.000">systemd-tmpfiles-setup.service (155ms)</text>
  <rect class="activating" x="234.846" y="780.000" width="0.000" height="19.000" />
  <rect class="active" x="234.846" y="780.000" width="1518.483" height="19.000" />
  <rect class="deactivating" x="1753.330" y="780.000" width="0.000" height="19.000" />
  <text class="left" x="239.846" y="794.000">sys-module-configfs.device</text>
  <rect class="activating" x="235.695" y="800.000" width="70.152" height="19.000" />
  <rect class="active" x="305.846" y="800.000" width="1447.483" height="19.000" />
  <rect class="deactivating" x="1753.330" y="800.000" width="0.000" height="19.000" />
  <text class="left" x="240.695" y="814.000">auditd.service (701ms)</text>
  <rect class="activating" x="235.897" y="820.000" width="63.946" height="19.000" />
  <rect class="active" x="299.843" y="820.000" width="1453.486" height="19.000" />
  <rect class="deactivating" x="1753.330" y="820.000" width="0.000" height="19.000" />
  <text class="left" x="240.897" y="834.000">var-lib-nfs-rpc_pipefs.mount (639ms)</text>
  <rect class="activating" x="260.633" y="840.000" width="0.000" height="19.000" />
  <rect class="active" x="260.633" y="840.000" width="1492.696" height="19.000" />
  <rect class="deactivating" x="1753.330" y="840.000" width="0.000" height="19.000" />
  <text class="left" x="265.633" y="854.000">dev-ttyS0.device</text>
  <rect class="activating" x="260.634" y="860.000" width="0.000" height="19.000" />
  <rect class="active" x="260.634" y="860.000" width="1492.696" height="19.000" />
  <rect class="deactivating" x="1753.330" y="860.000" width="0.000" height="19.000" />
  <text class="left" x="265.634" y="874.000">sys-devices-platform-serial8250-tty-ttyS0.device</text>
  <rect class="activating" x="262.595" y="880.000" width="0.000" height="19.000" />
  <rect class="active" x="262.595" y="880.000" width="1490.735" height="19.000" />
  <rect class="deactivating" x="1753.330" y="880.000" width="0.000" height="19.000" />
  <text class="left" x="267.595" y="894.000">dev-ttyS2.device</text>
  <rect class="activating" x="262.595" y="900.000" width="0.000" height="19.000" />
  <rect class="active" x="262.595" y="900.000" width="1490.735" height="19.000" />
  <rect class="deactivating" x="1753.330" y="900.000" width="0.000" height="19.000" />
  <text class="left" x="267.595" y="914.000">sys-devices-platform-serial8250-tty-ttyS2.device</text>
  <rect class="activating" x="262.655" y="920.000" width="0.000" height="19.000" />
  <rect class="active" x="262.655" y="920.000" width="1490.674" height="19.000" />
  <rect class="deactivating" x="1753.330" y="920.000" width="0.000" height="19.000" />
  <text class="left" x="267.655" y="934.000">dev-ttyS1.device</text>
  <rect class="activating" x="262.655" y="940.000" width="0.000" height="19.000" />
  <rect class="active" x="262.655" y="940.000" width="1490.674" height="19.000" />
  <rect class="deactivating" x="1753.330" y="940.000" width="0.000" height="19.000" />
  <text class="left" x="267.655" y="954.000">sys-devices-platform-serial8250-tty-ttyS1.device</text>
  <rect class="activating" x="264.450" y="960.000" width="0.000" height="19.000" />
  <rect class="active" x="264.450" y="960.000" width="1488.880" height="19.000" />
  <rect class="deactivating" x="1753.330" y="960.000" width="0.000" height="19.000" />
  <text class="left" x="269.450" y="974.000">dev-ttyS3.device</text>
  <rect class="activating" x="264.450" y="980.000" width="0.000" height="19.000" />
  <rect class="active" x="264.450" y="980.000" width="1488.880" height="19.000" />
  <rect class="deactivating" x="1753.330" y="980.000" width="0.000" height="19.000" />
  <text class="left" x="269.450" y="994.000">sys-devices-platform-serial8250-tty-ttyS3.device</text>
  <rect class="activating" x="287.589" y="1000.000" width="0.000" height="19.000" />
  <rect class="active" x="287.589" y="1000.000" width="1465.740" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1000.000" width="0.000" height="19.000" />
  <text class="left" x="292.589" y="1014.000">dev-disk-by\x2dpath-pci\x2d0000:00:01.1\x2data\x2d1.0.device</text>
  <rect class="activating" x="287.590" y="1020.000" width="0.000" height="19.000" />
  <rect class="active" x="287.590" y="1020.000" width="1465.740" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1020.000" width="0.000" height="19.000" />
  <text class="left" x="292.590" y="1034.000">dev-disk-by\x2did-ata\x2dVBOX_HARDDISK_VB6fa65a25\x2d72a41f6a.device</text>
  <rect class="activating" x="287.591" y="1040.000" width="0.000" height="19.000" />
  <rect class="active" x="287.591" y="1040.000" width="1465.738" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1040.000" width="0.000" height="19.000" />
  <text class="left" x="292.591" y="1054.000">dev-sda.device</text>
  <rect class="activating" x="287.591" y="1060.000" width="0.000" height="19.000" />
  <rect class="active" x="287.591" y="1060.000" width="1465.738" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1060.000" width="0.000" height="19.000" />
  <text class="left" x="292.591" y="1074.000">sys-devices-pci0000:00-0000:00:01.1-ata1-host0-target0:0:0-0:0:0:0-block-sda.device</text>
  <rect class="activating" x="294.357" y="1080.000" width="0.000" height="19.000" />
  <rect class="active" x="294.357" y="1080.000" width="1458.973" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1080.000" width="0.000" height="19.000" />
  <text class="left" x="299.357" y="1094.000">dev-disk-by\x2duuid-1c419d6c\x2d5064\x2d4a2b\x2d953c\x2d05b2c67edb15.device</text>
  <rect class="activating" x="294.357" y="1100.000" width="0.000" height="19.000" />
  <rect class="active" x="294.357" y="1100.000" width="1458.973" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1100.000" width="0.000" height="19.000" />
  <text class="left" x="299.357" y="1114.000">dev-disk-by\x2dpath-pci\x2d0000:00:01.1\x2data\x2d1.0\x2dpart1.device</text>
  <rect class="activating" x="294.357" y="1120.000" width="0.000" height="19.000" />
  <rect class="active" x="294.357" y="1120.000" width="1458.972" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1120.000" width="0.000" height="19.000" />
  <text class="left" x="299.357" y="1134.000">dev-disk-by\x2did-ata\x2dVBOX_HARDDISK_VB6fa65a25\x2d72a41f6a\x2dpart1.device</text>
  <rect class="activating" x="294.357" y="1140.000" width="0.000" height="19.000" />
  <rect class="active" x="294.357" y="1140.000" width="1458.972" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1140.000" width="0.000" height="19.000" />
  <text class="left" x="299.357" y="1154.000">sys-devices-pci0000:00-0000:00:01.1-ata1-host0-target0:0:0-0:0:0:0-block-sda-sda1.device</text>
  <rect class="activating" x="300.062" y="1160.000" width="0.000" height="19.000" />
  <rect class="active" x="300.062" y="1160.000" width="1453.267" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1160.000" width="0.000" height="19.000" />
  <text class="left" x="305.062" y="1174.000">rpc_pipefs.target</text>
  <rect class="activating" x="305.924" y="1180.000" width="1.962" height="19.000" />
  <rect class="active" x="307.886" y="1180.000" width="1445.444" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1180.000" width="0.000" height="19.000" />
  <text class="left" x="310.924" y="1194.000">systemd-update-utmp.service (19ms)</text>
  <rect class="activating" x="333.538" y="1200.000" width="0.000" height="19.000" />
  <rect class="active" x="333.538" y="1200.000" width="1419.792" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1200.000" width="0.000" height="19.000" />
  <text class="left" x="338.538" y="1214.000">swap.target</text>
  <rect class="activating" x="333.541" y="1220.000" width="0.000" height="19.000" />
  <rect class="active" x="333.541" y="1220.000" width="1419.789" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1220.000" width="0.000" height="19.000" />
  <text class="left" x="338.541" y="1234.000">sysinit.target</text>
  <rect class="activating" x="333.780" y="1240.000" width="0.000" height="19.000" />
  <rect class="active" x="333.780" y="1240.000" width="1419.549" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1240.000" width="0.000" height="19.000" />
  <text class="left" x="338.780" y="1254.000">dbus.socket</text>
  <rect class="activating" x="333.861" y="1260.000" width="0.000" height="19.000" />
  <rect class="active" x="333.861" y="1260.000" width="1419.469" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1260.000" width="0.000" height="19.000" />
  <text class="left" x="338.861" y="1274.000">rpcbind.socket</text>
  <rect class="activating" x="333.883" y="1280.000" width="0.000" height="19.000" />
  <rect class="active" x="333.883" y="1280.000" width="1419.447" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1280.000" width="0.000" height="19.000" />
  <text class="left" x="338.883" y="1294.000">sockets.target</text>
  <rect class="activating" x="334.029" y="1300.000" width="29.627" height="19.000" />
  <rect class="active" x="363.656" y="1300.000" width="1389.673" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1300.000" width="0.000" height="19.000" />
  <text class="left" x="339.029" y="1314.000">rpcbind.service (296ms)</text>
  <rect class="activating" x="334.125" y="1320.000" width="0.000" height="19.000" />
  <rect class="active" x="334.125" y="1320.000" width="1419.204" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1320.000" width="0.000" heiht="19.000" />
  <text class="left" x="339.125" y="1334.000">basic.target</text>
  <rect class="activating" x="334.658" y="1340.000" width="30.126" height="19.000" />
  <rect class="active" x="364.783" y="1340.000" width="1388.546" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1340.000" width="0.000" height="19.000" />
  <text class="left" x="339.658" y="1354.000">rhel-dmesg.service (301ms)</text>
  <rect class="activating" x="334.735" y="1360.000" width="42.420" height="19.000" />
  <rect class="active" x="377.156" y="1360.000" width="1376.174" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1360.000" width="0.000" height="19.000" />
  <text class="left" x="339.735" y="1374.000">polkit.service (424ms)</text>
  <rect class="activating" x="336.827" y="1380.000" width="42.761" height="19.000" />
  <rect class="active" x="379.588" y="1380.000" width="1373.742" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1380.000" width="0.000" height="19.000" />
  <text class="left" x="341.827" y="1394.000">chronyd.service (427ms)</text>
  <rect class="activating" x="337.206" y="1400.000" width="0.000" height="19.000" />
  <rect class="active" x="337.206" y="1400.000" width="33.733" height="19.000" />
  <rect class="deactivating" x="370.940" y="1400.000" width="0.000" height="19.000" />
  <text class="left" x="342.206" y="1414.000">irqbalance.service</text>
  <rect class="activating" x="337.528" y="1420.000" width="33.554" height="19.000" />
  <rect class="active" x="371.082" y="1420.000" width="1382.247" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1420.000" width="0.000" height="19.000" />
  <text class="left" x="342.528" y="1434.000">gssproxy.service (335ms)</text>
  <rect class="activating" x="340.515" y="1440.000" width="0.000" height="19.000" />
  <rect class="active" x="340.515" y="1440.000" width="1412.815" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1440.000" width="0.000" height="19.000" />
  <text class="left" x="345.515" y="1454.000">dbus.service</text>
  <rect class="activating" x="360.484" y="1460.000" width="17.135" height="19.000" />
  <rect class="active" x="377.619" y="1460.000" width="1375.711" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1460.000" width="0.000" height="19.000" />
  <text class="left" x="365.484" y="1474.000">systemd-logind.service (171ms)</text>
  <rect class="activating" x="360.622" y="1480.000" width="1383.878" height="19.000" />
  <rect class="active" x="1744.500" y="1480.000" width="8.829" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1480.000" width="0.000" height="19.000" />
  <text class="left" x="365.622" y="1494.000">vboxadd.service (13.838s)</text>
  <rect class="activating" x="360.649" y="1500.000" width="0.000" height="19.000" />
  <rect class="active" x="360.649" y="1500.000" width="1392.680" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1500.000" width="0.000" height="19.000" />
  <text class="left" x="365.649" y="1514.000">systemd-tmpfiles-clean.timer</text>
  <rect class="activating" x="360.680" y="1520.000" width="0.000" height="19.000" />
  <rect class="active" x="360.680" y="1520.000" width="1392.649" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1520.000" width="0.000" height="19.000" />
  <text class="left" x="365.680" y="1534.000">timers.target</text>
  <rect class="activating" x="378.037" y="1540.000" width="305.214" height="19.000" />
  <rect class="active" x="683.251" y="1540.000" width="1070.079" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1540.000" width="0.000" height="19.000" />
  <text class="left" x="383.037" y="1554.000">firewalld.service (3.052s)</text>
  <rect class="activating" x="378.095" y="1560.000" width="0.000" height="19.000" />
  <rect class="active" x="378.095" y="1560.000" width="1375.235" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1560.000" width="0.000" height="19.000" />
  <text class="left" x="383.095" y="1574.000">nfs-client.target</text>
  <rect class="activating" x="378.133" y="1580.000" width="0.000" height="19.000" />
  <rect class="active" x="378.133" y="1580.000" width="1375.197" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1580.000" width="0.000" height="19.000" />
  <text class="left" x="383.133" y="1594.000">remote-fs-pre.target</text>
  <rect class="activating" x="378.172" y="1600.000" width="0.000" height="19.000" />
  <rect class="active" x="378.172" y="1600.000" width="1375.157" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1600.000" width="0.000" height="19.000" />
  <text class="left" x="383.172" y="1614.000">remote-fs.target</text>
  <rect class="activating" x="378.268" y="1620.000" width="11.095" height="19.000" />
  <rect class="active" x="389.364" y="1620.000" width="1363.966" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1620.000" width="0.000" height="19.000" />
  <text class="left" x="383.268" y="1634.000">systemd-user-sessions.service (110ms)</text>
  <rect class="activating" x="389.677" y="1640.000" width="0.000" height="19.000" />
  <rect class="active" x="389.677" y="1640.000" width="1363.653" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1640.000" width="0.000" height="19.000" />
  <text class="left" x="394.677" y="1654.000">getty@tty1.service</text>
  <rect class="activating" x="389.843" y="1660.000" width="0.000" height="19.000" />
  <rect class="active" x="389.843" y="1660.000" width="1363.486" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1660.000" width="0.000" height="19.000" />
  <text class="left" x="394.843" y="1674.000">getty.target</text>
  <rect class="activating" x="390.991" y="1680.000" width="0.000" height="19.000" />
  <rect class="active" x="390.991" y="1680.000" width="1362.338" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1680.000" width="0.000" height="19.000" />
  <text class="left" x="395.991" y="1694.000">crond.service</text>
  <rect class="activating" x="683.504" y="1700.000" width="0.000" height="19.000" />
  <rect class="active" x="683.504" y="1700.000" width="1069.826" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1700.000" width="0.000" height="19.000" />
  <text class="left" x="688.504" y="1714.000">network-pre.target</text>
  <rect class="activating" x="933.250" y="1720.000" width="0.000" height="19.000" />
  <rect class="active" x="933.250" y="1720.000" width="820.080" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1720.000" width="0.000" height="19.000" />
  <text class="right" x="928.250" y="1734.000">sys-devices-pci0000:00-0000:00:05.0-sound-card0.device</text>
  <rect class="activating" x="933.270" y="1740.000" width="0.000" height="19.000" />
  <rect class="active" x="933.270" y="1740.000" width="820.060" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1740.000" width="0.000" height="19.000" />
  <text class="right" x="928.270" y="1754.000">sound.target</text>
  <rect class="activating" x="1052.062" y="1760.000" width="0.000" height="19.000" />
  <rect class="active" x="1052.062" y="1760.000" width="701.267" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1760.000" width="0.000" height="19.000" />
  <text class="right" x="1047.062" y="1774.000">sys-subsystem-net-devices-eth0.device</text>
  <rect class="activating" x="1052.062" y="1780.000" width="0.000" height="19.000" />
  <rect class="active" x="1052.062" y="1780.000" width="701.267" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1780.000" width="0.000" height="19.000" />
  <text class="right" x="1047.062" y="1794.000">sys-devices-pci0000:00-0000:00:03.0-net-eth0.device</text>
  <rect class="activating" x="1061.841" y="1800.000" width="0.000" height="19.000" />
  <rect class="active" x="1061.841" y="1800.000" width="691.488" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1800.000" width="0.000" height="19.000" />
  <text class="right" x="1056.841" y="1814.000">sys-subsystem-net-devices-eth1.device</text>
  <rect class="activating" x="1061.841" y="1820.000" width="0.000" height="19.000" />
  <rect class="active" x="1061.841" y="1820.000" width="691.488" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1820.000" width="0.000" height="19.000" />
  <text class="right" x="1056.841" y="1834.000">sys-devices-pci0000:00-0000:00:08.0-net-eth1.device</text>
  <rect class="activating" x="1273.767" y="1840.000" width="134.317" height="19.000" />
  <rect class="active" x="1408.084" y="1840.000" width="345.245" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1840.000" width="0.000" height="19.000" />
  <text class="right" x="1268.767" y="1854.000">network.service (1.343s)</text>
  <rect class="activating" x="1408.400" y="1860.000" width="0.000" height="19.000" />
  <rect class="active" x="1408.400" y="1860.000" width="344.930" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1860.000" width="0.000" height="19.000" />
  <text class="right" x="1403.400" y="1874.000">network.target</text>
  <rect class="activating" x="1408.435" y="1880.000" width="0.000" height="19.000" />
  <rect class="active" x="1408.435" y="1880.000" width="344.895" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1880.000" width="0.000" height="19.000" />
  <text class="right" x="1403.435" y="1894.000">network-online.target</text>
  <rect class="activating" x="1408.783" y="1900.000" width="5.905" height="19.000" />
  <rect class="active" x="1414.688" y="1900.000" width="0.000" height="19.000" />
  <rect class="deactivating" x="1414.688" y="1900.000" width="0.000" height="19.000" />
  <text class="right" x="1403.783" y="1914.000">rpc-statd-notify.service (59ms)</text>
  <rect class="activating" x="1409.031" y="1920.000" width="7.244" height="19.000" />
  <rect class="active" x="1416.275" y="1920.000" width="337.054" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1920.000" width="0.000" height="19.000" />
  <text class="right" x="1404.031" y="1934.000">rsyslog.service (72ms)</text>
  <rect class="activating" x="1409.191" y="1940.000" width="166.121" height="19.000" />
  <rect class="active" x="1575.311" y="1940.000" width="178.018" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1940.000" width="0.000" height="19.000" />
  <text class="right" x="1404.191" y="1954.000">tuned.service (1.661s)</text>
  <rect class="activating" x="1409.460" y="1960.000" width="12.519" height="19.000" />
  <rect class="active" x="1421.979" y="1960.000" width="331.350" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1960.000" width="0.000" height="19.000" />
  <text class="right" x="1404.460" y="1974.000">sshd.service (125ms)</text>
  <rect class="activating" x="1409.602" y="1980.000" width="217.102" height="19.000" />
  <rect class="active" x="1626.705" y="1980.000" width="126.625" height="19.000" />
  <rect class="deactivating" x="1753.330" y="1980.000" width="0.000" height="19.000" />
  <text class="right" x="1404.602" y="1994.000">postfix.service (2.171s)</text>
  <rect class="activating" x="1744.794" y="2000.000" width="6.793" height="19.000" />
  <rect class="active" x="1751.587" y="2000.000" width="1.742" height="19.000" />
  <rect class="deactivating" x="1753.330" y="2000.000" width="0.000" height="19.000" />
  <text class="right" x="1739.794" y="2014.000">vboxadd-service.service (67ms)</text>
  <rect class="activating" x="1751.637" y="2020.000" width="0.000" height="19.000" />
  <rect class="active" x="1751.637" y="2020.000" width="1.693" height="19.000" />
  <rect class="deactivating" x="1753.330" y="2020.000" width="0.000" height="19.000" />
  <text class="right" x="1746.637" y="2034.000">multi-user.target</text>
  <rect class="activating" x="1751.872" y="2040.000" width="1.298" height="19.000" />
  <rect class="active" x="1753.171" y="2040.000" width="0.000" height="19.000" />
  <rect class="deactivating" x="1753.171" y="2040.000" width="0.000" height="19.000" />
  <text class="right" x="1746.872" y="2054.000">systemd-update-utmp-runlevel.service (12ms)</text>
</g>
<g transform="translate(20,100)">
  <rect class="activating" x="0.000" y="2080.000" width="30.000" height="19.000" />
  <text class="left" x="45.000" y="2094.000">Activating</text>
  <rect class="active" x="0.000" y="2100.000" width="30.000" height="19.000" />
  <text class="left" x="45.000" y="2114.000">Active</text>
  <rect class="deactivating" x="0.000" y="2120.000" width="30.000" height="19.000" />
  <text class="left" x="45.000" y="2134.000">Deactivating</text>
  <rect class="security" x="0.000" y="2140.000" width="30.000" height="19.000" />
  <text class="left" x="45.000" y="2154.000">Setting up security module</text>
  <rect class="generators" x="0.000" y="2160.000" width="30.000" height="19.000" />
  <text class="left" x="45.000" y="2174.000">Generators</text>
  <rect class="unitsload" x="0.000" y="2180.000" width="30.000" height="19.000" />
  <text class="left" x="45.000" y="2194.000">Loading unit files</text>
</g>

</svg>
```


