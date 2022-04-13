#!/bin/bash
set -e
txtrst=$(tput sgr0) # Text reset
txtred=$(tput setaf 1) # Red
txtblu=$(tput setaf 4) # Blue

DIR=$(dirname "$0")
pushd $DIR

echo "Get public cert for sealing secret"

echo "📦 Save public cert in ${txtblu}$(pwd)/public-cert.pem${txtrst}"
set -x
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key -o jsonpath="{.items[0].data['tls\.crt']}" | base64 -d > public-cert.pem 

{ set +x; } 2> /dev/null # silently disable xtrace
popd