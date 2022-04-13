#!/bin/bash
echo "Update argocd passwd"

# The initial password is set in a kubernetes secret, named argocd-secret, during ArgoCD's initial start up with the name of the pod of argocd-server
export PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

argocd login \
    --insecure \
    --username admin \
    --password $PASS \
    --grpc-web \
    argocd.$IP.sslip.io

echo "Change echo old password $PASS with demo password : <argodemo>, don't do this it's bad !"
argocd account update-password --current-password $PASS --new-password argodemo

