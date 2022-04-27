#!/bin/bash
. demo-magic.sh

set -e
txtrst=$(tput sgr0) # Text reset
txtred=$(tput setaf 1) # Red
txtblu=$(tput setaf 4) # Blue

DIR=$(dirname "$0")

pushd $DIR

clear


prompt "👮 - Install SealedSecret Controller"
pe "kubectl apply -f sealed-secret-ctrl-v0.17.5.yml --wait"


echo "Get public cert for sealing secret"

# The initial password is set in a kubernetes secret, named argocd-secret, during ArgoCD's initial start up with the name of the pod of argocd-server
# waiting...
echo ""
echo "⏳ - Waiting for public cert "
while [ "" == "$(kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o json | jq -r '.items[] | has("kind")')" ]; do echo -n "."; sleep 1; done
echo " ✅"

prompt "📦 - Save public cert in ${txtblu}$(pwd)/public-cert.pem${txtrst}"
pe "kubeseal --fetch-cert > public-cert.pem"

popd
