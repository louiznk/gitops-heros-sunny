L'ingress est en https
pour installer cela il faut avoir l'IP en env
Si civo
```
source ../civo-k3s/set-kube-config-and-envs.fish
```

```
./01-install_argo.sh
./02-update_argo_pwd.sh
./03-login_to_argo.sh
```