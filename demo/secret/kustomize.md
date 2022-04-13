On peut profiter d'une fonctionnalité non documenter

https://github.com/kubernetes-sigs/kustomize/blob/master/examples/secretGeneratorPlugin.md

en utilisant un fichier env clef valeurs sans valeurs

kustomize.yml
```yaml
#...
secretGenerator:
- name: james-secrets
  envs:
  - .env.secret
```
.env.secret
```properties
secret
```

```sh
secret="mon secret pas si secret" kustomize build .
```
Intégration ArgoCD : Marche pas, faut faire sont plugin
https://argo-cd.readthedocs.io/en/stable/user-guide/config-management-plugins/#environment

```yaml
spec:
#...
  source:
    plugin:
      env:
        - name: secret
          value: mon secret pas si secret

```
KO DOC PAS A JOURS !!!!
Du coup version 
.env.secret
```properties
secret=un secret comme un autre
```

Par contre avec gitlab on fait ce que l'on veut...