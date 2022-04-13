# Principe
https://github.com/bitnami-labs/sealed-secrets

Utilise un chiffrement assymétrique.  
La clef privé est sur le serveur, la clef public est dispo pour tous et sert à chiffrer le secret.

Il y a une ressource spécifique de type `SealedSecret` qui contient le(s) secret(s) chiffré(s) avec la clef public.  
Le `SealSecret` est transformé et `Secret` par un operateur qui connait la clef privé

## Installation

Installer l'opérateur

```
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.16.0/controller.yaml  
```


Installer le client 0.16.0
(asdf)


## Usage

Secret => kubeseal => SeleadSecret

<!> essaille de se connecter au POD <!>
### Créer un sealed secret (connecté demande accès au POD) 
```
kubectl create secret generic secret-name --dry-run=client --from-literal=foo=bar -o yaml | \
 kubeseal \
 --controller-name=sealed-secrets-controller \
 --controller-namespace=kube-system \
 --format yaml > mysealedsecret.yaml
```

Cela nécessite d'accéder au cluster. 

### Créer un sealed secret (deconnecté) 
Si l'on veut pouvoir générer les selead secret sans connexion au cluster (utile par exemple pour de la prod)

1. récupération du certificat public 

Sans accès au pod : stocké dans un secret

```
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o jsonpath="{.items[0].data['tls\.crt']}" | base64 -d > public-cert.pem 
```



Avec accès au pod

```
kubeseal \
 --fetch-cert > public-cert.pem
```

2. utilisation du certificat public (en offline)

Génération d'un sealed secret pour un secret "mon-secret"
```
kubectl create secret generic mon-secret --dry-run=client --from-literal=foo=bar -o yaml | \
kubeseal --format yaml --cert public-cert.pem > mysealedsecret.yaml
```


#### Notes kustomize :  
Option --scope qui permet de rendre les secrets réutilisable dans d'autres namespaces ou avec d'autres noms (utile pour kustomize si l'on fait des secrets kustomize avec les generator standard qui ajoutent un hash aux config et secrets, voir `disableNameSuffixHash: true` https://github.com/kubernetes-sigs/kustomize/blob/master/examples/generatorOptions.md pour desactiver ce fonctionnement)
```
      --scope string                     Set the scope of the sealed secret: strict, namespace-wide, cluster-wide (defaults to strict). Mandatory for --raw, otherwise the 'sealedsecrets.bitnami.com/cluster-wide' and 'sealedsecrets.bitnami.com/namespace-wide' annotations on the input secret can be used to select the scope. (default "strict")
```
voir https://dev.to/stack-labs/store-your-kubernetes-secrets-in-git-thanks-to-kubeseal-hello-sealedsecret-2i6h

#### Notes helm :

Faire un SealedSecret avec les différentes valeurs sealed grace à la commande --raw

```
echo -n "ceci est un secret" | kubeseal --raw --cert public-cert.pem --scope namespace-wide
```

Le SealedSecret multi env

```yaml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: {{ include "balrog.fullname" . }}
  annotations:
    sealedsecrets.bitnami.com/namespace-wide: "true"
  labels:
    {{- include "balrog.labels" . | nindent 4 }}
spec:
  encryptedData:
    foo: {{ .Values.sealedSecrets.secretFoo }}
  template:
    metadata:
      name: mon-secret
      labels:
        {{- include "balrog.labels" . | nindent 8 }}

```


```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: busybox
    volumeMounts:
    - name: secret-volume
      mountPath: "/etc/secrets"
      readOnly: true
  volumes:
  - name: secret-vlume
    secret:
      secretName: mon-secret
```

Fichier values.yaml
```yaml
...
secrets:
  foo: AgBJMJ28fa2hsmKW2CgAGI55OGu5vuqGv/m1SMw+ubIWmKCPSpg4DQZyrcVmWnIbEf9erg/VCY6QCGpyaNjFTcnk+TEYVqHdyvPj8BF1RV28Bp2IuXui7NwK6peyrI8gwBE3oBk6avFJEus8oCBkt0A6WY6kLIE2s+FTtZ+vNStPK1Vrs5ONRLfqUuLcv1t2QPL/2HuWonga5LwHuLrv4ZYW+MEniIOGIvw2QYSwLDtjBJf5Tb49B6eX12/xGOgQ4A5sEoYObGiNutR81qZsMR1Gt2kq1C+ARMEm39q81VUVny7peNlYeMbWoColCcHEbOwa2JklHFUmFsApCrNmqBITfGQKpJDiqNHFnGp8NU3GjSLgrIL/SYmw8gF3A8p9dfxCgP+UzR7q8zZT3kNGOZPR6SQ1ZPC5ujXRSRX5Pt1tN402vCltrBM/XPddMFA7iDEU/5WbEGmITxNX47g/I1R7M2VA819hr3vTd9gehH5eeH5CgSA3NZrQMOHjYP5ZRh9ZQ9Bn85O7hw5nGttYG5CRaEBeLRnyNG47zRWW26XM6vvLUyCre/FP0t2mcWYE6zVqCK4Ks4DL9nr8Dzb7xAfOGhQj1MXg0wdJ/KuQcbrSnMObST7BvZMYEFDPa98F7mCab5tGNaRtkvzJAaPY/ETXC/E8GPEFNJNP1Kv9U50bZVnYdG4vVyL/Z9J48SWR5oH8LZs/FuCapqJTRO2ZkNid8zQ=
```

### Résultat du sealed secret (forcement connecté)



```
kubectl apply -f mysealedsecret.yaml
```

L'operator va généré un secret du SealedSecret déchiffé

```
kubectl get sealedsecrets,secret
```
```
NAME                                  AGE
sealedsecret.bitnami.com/mon-secret   74s

NAME                         TYPE                                  DATA   AGE
secret/default-token-qj8r4   kubernetes.io/service-account-token   3      2d6h
secret/mon-secret            Opaque                                1      74s
```


```
k get secret mon-secret -o yaml                                                                                                                 
apiVersion: v1
data:
  foo: YmFy
kind: Secret
metadata:
  creationTimestamp: "2021-11-06T18:56:02Z"
  name: mon-secret
  namespace: default
  ownerReferences:
  - apiVersion: bitnami.com/v1alpha1
    controller: true
    kind: SealedSecret
    name: mon-secret
    uid: 2cb0d6c7-b17e-41e7-99c5-819b02858190
  resourceVersion: "159348"
  uid: 05637412-e8e7-40b1-aa9e-bf813d576a6b
type: Opaque


k get secret mon-secret -o jsonpath="{.data.foo}" | base64 -d                                                                                   
bar⏎                                                                
```

Voir https://faun.pub/sealing-secrets-with-kustomize-51d1b79105d8


Secret sera a monter dans /etc/sith/secret