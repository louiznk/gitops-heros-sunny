#!/bin/bash
set -e
txtrst=$(tput sgr0) # Text reset
txtred=$(tput setaf 1) # Red
txtblu=$(tput setaf 4) # Blue

DIR=$(dirname "$0")
echo "👮 Install SealedSecret Controller"

pushd $DIR
set -x
kubectl apply -f sealed-secret-ctrl-v0.16.0.yml --wait


{ set +x; } 2> /dev/null # silently disable xtrace
echo "Get public cert for sealing secret"

# The initial password is set in a kubernetes secret, named argocd-secret, during ArgoCD's initial start up with the name of the pod of argocd-server
# waiting...
echo "⏳ Waiting for public cert"
while [ "" == "$(kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o json | jq -r '.items[] | has("kind")')" ]; do echo -n "."; sleep 1; done
echo " ✅"

echo "📦 Save public cert in ${txtblu}$(pwd)/public-cert.pem${txtrst}"
set -x
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o jsonpath="{.items[0].data['tls\.crt']}" | base64 -d > public-cert.pem 

popd
