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
(afficher le contenu)

ExecStart: Il s'agit de la commande éffectuée lors de l'exécution de ce service

ExecStartPre: Il s'agit des commandes éffectuée avant celles lancées par ExecStart

PIDFile: Cette option permet de spécifier le chemin d'accès au fichier PID du service.

Type: Configure le type du ou des processus qui seront lancés par le service.

ExecReload: Indique la commande à effectuer pour lancer un reload du service.

Description: Le nom du service lisible et clair pour les devs.

After: Indique ce qui est nécéssaire d'être exécuté Pour le lancement du service et qui doit être lancé avant ce dernier.

Liste de tous les services qui contiennent la ligne WantedBy=multi-user.target

grep -r  /usr/lib/systemd/system -e WantedBy=multi-user.target

## Partie 3: Création de service
