Utilisation d'un Secret classique via templating avecinjection de la valeur avec --set et inclusion de la commande base64 dans le chart pour ne pas gérer l'encodage

Cela fait à l'execution un truc du genre (voir ce qui est fait dans le repo)


helm install prod --create-namespace -n demo02-helm-prod --dry-run --debug . --set secrets.create=true --set secrets.supersecret=DSfihfief
